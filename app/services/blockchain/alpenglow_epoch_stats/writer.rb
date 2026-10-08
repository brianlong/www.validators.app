# frozen_string_literal: true

module Blockchain
  module AlpenglowEpochStats
    class Writer
      def initialize(network:, logger:)
        @network = network
        @logger = logger
      end

      def call(leader_counters:, voting_counters:, user_agents:)
        rows = Hash.new { |hash, key| hash[key] = { values: Hash.new(0), user_agent: nil } }
        add_leader_rows(rows, leader_counters, user_agents)
        add_voting_rows(rows, voting_counters)

        upsert_with_increment(build_rows(rows)) if rows.any?
      end

      private

      def add_leader_rows(rows, counters, user_agents)
        vote_accounts = leader_vote_accounts(counters.keys)

        counters.each do |key, values|
          vote_account = vote_accounts[key]
          if vote_account.nil?
            @logger.warn("Skipping leader #{key.last} on #{@network}: validator or vote account not found")
            next
          end

          row = rows[[key.first, vote_account]]
          values.each { |counter, value| row[:values][counter] += value }
          row[:user_agent] = user_agents[key] || row[:user_agent]
        end
      end

      def add_voting_rows(rows, counters)
        vote_accounts = vote_accounts_by_address(counters.keys.map(&:last).uniq)

        counters.each do |(epoch, address), values|
          vote_account = vote_accounts[address]
          if vote_account.nil?
            @logger.warn("Skipping vote account #{address} on #{@network}: not found")
            next
          end

          values.each { |counter, value| rows[[epoch, vote_account]][:values][counter] += value }
        end
      end

      def leader_vote_accounts(keys)
        leaders = keys.map(&:last).uniq
        ranked = AlpenglowEpochRank.settled
                                   .where(network: @network, epoch: keys.map(&:first).uniq, validator_identity: leaders)
                                   .pluck(:epoch, :validator_identity, :vote_account)
        by_address = vote_accounts_by_address(ranked.map(&:last))
        by_rank = ranked.to_h { |epoch, identity, address| [[epoch, identity], by_address[address]] }
        active = active_vote_accounts(leaders)

        keys.to_h { |key| [key, by_rank[key] || active[key.last]] }
      end

      def active_vote_accounts(leaders)
        Validator.where(network: @network, account: leaders).includes(:vote_accounts).each_with_object({}) do |validator, map|
          vote_account = validator.vote_account_active
          map[validator.account] = vote_account if vote_account
        end
      end

      def vote_accounts_by_address(addresses)
        VoteAccount.where(network: @network, account: addresses).index_by(&:account)
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
        connection = AlpenglowValidatorEpochStat.connection
        columns = rows.first.keys
        values = rows.map { |row| "(#{columns.map { |column| connection.quote(row[column]) }.join(', ')})" }
        updates = COUNTERS.map { |counter| "#{table}.#{counter} = #{table}.#{counter} + new_values.#{counter}" }
        updates << "#{table}.last_block_user_agent = COALESCE(new_values.last_block_user_agent, #{table}.last_block_user_agent)"
        updates << "#{table}.updated_at = new_values.updated_at"

        connection.execute(<<~SQL.squish)
          INSERT INTO #{table} (#{columns.join(', ')})
          VALUES #{values.join(', ')} AS new_values
          ON DUPLICATE KEY UPDATE #{updates.join(', ')}
        SQL
      end
    end
  end
end
