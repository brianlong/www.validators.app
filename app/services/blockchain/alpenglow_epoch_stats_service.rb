# frozen_string_literal: true

module Blockchain
  class AlpenglowEpochStatsService
    BATCH_SIZE = 5_000
    FINALITY_LAG = 32
    DEDUP_WINDOW = 64

    LEADER_COUNTERS = %i[
      leader_slots
      leader_slots_with_final_cert
      leader_fast_finalized
      leader_slow_finalized
      leader_final_lag_sum
    ].freeze

    VOTING_COUNTERS = %i[
      notar_reward_slots
      notar_votes
      fast_finalized_slots
      fast_final_signatures
      slow_finalized_slots
      slow_final_signatures
      slow_notar_signatures
      skip_votes
      divergent_skip_votes
    ].freeze

    COUNTERS = (LEADER_COUNTERS + VOTING_COUNTERS).freeze

    CERTIFICATES = {
      final: :final_cert_slot,
      notar_reward: :notar_reward_slot,
      skip_reward: :skip_reward_slot
    }.freeze

    LOG_PATH = Rails.root.join("log", "#{name.demodulize.underscore}.log")

    def initialize(network:, epoch_schedule: nil)
      @network = network
      @footer_class = Blockchain::BlockFooter.network(network)
      @epoch_schedule = epoch_schedule
      @logger = Logger.new(LOG_PATH)
    end

    def call
      footers = pending_footers
      return 0 if footers.empty?

      certificates = first_certificates(footers)
      footers, certificates = processable(footers, certificates)
      return 0 if footers.empty?

      leader_counters = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      voting_counters = Hash.new { |hash, key| hash[key] = Hash.new(0) }
      user_agents = {}

      count_produced_blocks(footers, leader_counters, user_agents)
      count_finalizations(certificates[:final], leader_counters)
      count_votes(certificates, voting_counters)

      ApplicationRecord.transaction do
        save_counters(leader_counters, voting_counters, user_agents)
        @footer_class.where(id: footers.map(&:id)).update_all(processed: true, updated_at: Time.current)
      end

      @logger.info("Processed #{footers.size} footers up to slot #{footers.last.slot_number} on #{@network}")
      footers.size
    end

    private

    def epoch_schedule
      @epoch_schedule ||= begin
        url = Rails.application.credentials.solana["#{@network.tr('-', '_')}_urls".to_sym][0]
        Blockchain::EpochSchedule.new(SolanaRpcClient.new(cluster: url).client.get_epoch_schedule.result)
      end
    end

    def pending_footers
      max_slot = @footer_class.maximum(:slot_number)
      return [] if max_slot.nil?

      @footer_class.where(processed: false)
                   .where("slot_number <= ?", max_slot - FINALITY_LAG)
                   .order(:slot_number)
                   .limit(BATCH_SIZE)
                   .to_a
    end

    def first_certificates(footers)
      first_slot = footers.first.slot_number
      previous = @footer_class.where(slot_number: (first_slot - DEDUP_WINDOW)...first_slot)
                              .pluck(*CERTIFICATES.values)

      CERTIFICATES.each_with_index.to_h do |(type, column), index|
        already_seen = previous.map { |values| values[index] }.compact.to_set
        firsts = {}
        footers.each do |footer|
          slot = footer.public_send(column)
          next if slot.nil? || already_seen.include?(slot) || firsts.key?(slot)

          firsts[slot] = footer
        end
        [type, firsts]
      end
    end

    def processable(footers, certificates)
      statuses = rank_statuses(certificates.values.flat_map(&:keys).map { |slot| epoch_schedule.epoch_for(slot) }.uniq)
      blocked_at = certificates.values.flat_map do |firsts|
        firsts.filter_map { |slot, footer| footer.slot_number if statuses[epoch_schedule.epoch_for(slot)] == :pending }
      end.min
      return [footers, certificates] if blocked_at.nil?

      @logger.info("Waiting for finalized ranks on #{@network}, stopping before slot #{blocked_at}")
      kept = footers.take_while { |footer| footer.slot_number < blocked_at }
      kept_certificates = certificates.transform_values do |firsts|
        firsts.select { |_, footer| footer.slot_number < blocked_at }
      end
      [kept, kept_certificates]
    end

    def rank_statuses(epochs)
      counts = AlpenglowEpochRank.where(network: @network, epoch: epochs).group(:epoch, :finalized).count
      epochs.index_with do |epoch|
        if counts[[epoch, true]].to_i.positive?
          :finalized
        elsif counts[[epoch, false]].to_i.positive?
          :pending
        else
          :missing
        end
      end
    end

    def count_produced_blocks(footers, counters, user_agents)
      footers.each do |footer|
        next if footer.leader.blank?

        key = [footer.epoch, footer.leader]
        counters[key][:leader_slots] += 1
        counters[key][:leader_slots_with_final_cert] += 1 if footer.final_cert_slot
        user_agents[key] = footer.block_user_agent if footer.block_user_agent.present?
      end
    end

    def count_finalizations(final_certificates, counters)
      finalized_blocks = @footer_class.where(slot_number: final_certificates.keys).pluck(:slot_number, :epoch, :leader)

      finalized_blocks.each do |slot, epoch, leader|
        next if leader.blank?

        footer = final_certificates[slot]
        key = [epoch, leader]
        counters[key][footer.fast? ? :leader_fast_finalized : :leader_slow_finalized] += 1
        counters[key][:leader_final_lag_sum] += footer.slot_number - slot
      end
    end

    def count_votes(certificates, counters)
      ranks = finalized_ranks(certificates)
      notarized = notarized_slots(certificates[:skip_reward].keys)

      certificates[:notar_reward].each do |slot, footer|
        each_ranked(ranks, slot) do |epoch, vote_accounts|
          vote_accounts.each { |vote_account| counters[[epoch, vote_account]][:notar_reward_slots] += 1 }
          signers(vote_accounts, footer.notar_reward_signers).each do |vote_account|
            counters[[epoch, vote_account]][:notar_votes] += 1
          end
        end
      end

      certificates[:final].each do |slot, footer|
        each_ranked(ranks, slot) do |epoch, vote_accounts|
          kind = footer.fast? ? :fast : :slow
          vote_accounts.each { |vote_account| counters[[epoch, vote_account]][:"#{kind}_finalized_slots"] += 1 }
          signers(vote_accounts, footer.final_signers).each do |vote_account|
            counters[[epoch, vote_account]][:"#{kind}_final_signatures"] += 1
          end
          signers(vote_accounts, footer.final_notar_signers).each do |vote_account|
            counters[[epoch, vote_account]][:slow_notar_signatures] += 1
          end
        end
      end

      certificates[:skip_reward].each do |slot, footer|
        each_ranked(ranks, slot) do |epoch, vote_accounts|
          signers(vote_accounts, footer.skip_reward_signers).each do |vote_account|
            counters[[epoch, vote_account]][:skip_votes] += 1
            counters[[epoch, vote_account]][:divergent_skip_votes] += 1 if notarized.include?(slot)
          end
        end
      end
    end

    def finalized_ranks(certificates)
      epochs = certificates.values.flat_map(&:keys).map { |slot| epoch_schedule.epoch_for(slot) }.uniq
      AlpenglowEpochRank.finalized.where(network: @network, epoch: epochs).order(:rank)
                        .pluck(:epoch, :vote_account)
                        .group_by(&:first)
                        .transform_values { |rows| rows.map(&:last) }
    end

    def each_ranked(ranks, slot)
      epoch = epoch_schedule.epoch_for(slot)
      vote_accounts = ranks[epoch]
      yield epoch, vote_accounts if vote_accounts
    end

    def signers(vote_accounts, bytes)
      return [] if bytes.blank?

      decoded = Blockchain::AlpenglowFooterDecoder.decode_signers(bytes)
      (decoded[:ranks] + decoded.fetch(:fallback_ranks, [])).uniq.filter_map { |rank| vote_accounts[rank] }
    end

    def notarized_slots(skip_slots)
      return Set.new if skip_slots.empty?

      @footer_class.where(slot_number: skip_slots.min..(skip_slots.max + DEDUP_WINDOW))
                   .where(notar_reward_slot: skip_slots)
                   .distinct
                   .pluck(:notar_reward_slot)
                   .to_set
    end

    def save_counters(leader_counters, voting_counters, user_agents)
      rows = Hash.new { |hash, key| hash[key] = { values: Hash.new(0), user_agent: nil } }

      leader_vote_accounts(leader_counters.keys.map(&:last).uniq).then do |by_leader|
        leader_counters.each do |(epoch, leader), values|
          vote_account = by_leader[leader]
          next @logger.warn("Skipping leader #{leader} on #{@network}: validator or vote account not found") if vote_account.nil?

          row = rows[[epoch, vote_account]]
          values.each { |counter, value| row[:values][counter] += value }
          row[:user_agent] = user_agents[[epoch, leader]] || row[:user_agent]
        end
      end

      voting_vote_accounts(voting_counters.keys.map(&:last).uniq).then do |by_account|
        voting_counters.each do |(epoch, account), values|
          vote_account = by_account[account]
          next @logger.warn("Skipping vote account #{account} on #{@network}: not found") if vote_account.nil?

          values.each { |counter, value| rows[[epoch, vote_account]][:values][counter] += value }
        end
      end

      upsert_with_increment(build_rows(rows)) if rows.any?
    end

    def leader_vote_accounts(leaders)
      Validator.where(network: @network, account: leaders).includes(:vote_accounts).each_with_object({}) do |validator, map|
        vote_account = validator.vote_account_active
        map[validator.account] = vote_account if vote_account
      end
    end

    def voting_vote_accounts(accounts)
      VoteAccount.where(network: @network, account: accounts).index_by(&:account)
    end

    def build_rows(rows)
      now = Time.current
      rows.map do |(epoch, vote_account), row|
        COUNTERS.to_h { |counter| [counter, row[:values][counter]] }.merge(
          network: @network,
          epoch: epoch,
          vote_account_id: vote_account.id,
          validator_id: vote_account.validator_id,
          last_block_user_agent: row[:user_agent],
          created_at: now,
          updated_at: now
        )
      end
    end

    def upsert_with_increment(rows)
      table = AlpenglowValidatorEpochStat.table_name
      columns = rows.first.keys
      values = rows.map do |row|
        "(#{columns.map { |column| ApplicationRecord.connection.quote(row[column]) }.join(', ')})"
      end
      updates = COUNTERS.map { |counter| "#{table}.#{counter} = #{table}.#{counter} + new_values.#{counter}" }
      updates << "#{table}.last_block_user_agent = COALESCE(new_values.last_block_user_agent, #{table}.last_block_user_agent)"
      updates << "#{table}.updated_at = new_values.updated_at"

      ApplicationRecord.connection.execute(<<~SQL.squish)
        INSERT INTO #{table} (#{columns.join(', ')})
        VALUES #{values.join(', ')} AS new_values
        ON DUPLICATE KEY UPDATE #{updates.join(', ')}
      SQL
    end
  end
end
