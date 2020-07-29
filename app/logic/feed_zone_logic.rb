# frozen_string_literal: true

# Logic to compile data for the feed_zone
module FeedZoneLogic
  include PipelineLogic
  PAYLOAD_VERSION = 1

  # Payload starts with :network & :batch_uuid
  def set_this_batch
    lambda do |p|
      return p unless p.code == 200

      this_batch = Batch.where(
        network: p.payload[:network],
        uuid: p.payload[:batch_uuid]
      ).first

      if this_batch.nil?
        raise "No batch: #{p.payload[:network]}, #{p.payload[:batch_uuid]}"
      end

      Pipeline.new(200, p.payload.merge(this_batch: this_batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def set_previous_batch
    lambda do |p|
      return p unless p.code == 200

      prev_batch = Batch.where(
        ['network = ? AND created_at < ?',
         p.payload[:network],
         p.payload[:this_batch].created_at]
      ).last
      # Note: It is acceptable for prev_batch to be nil.

      Pipeline.new(200, p.payload.merge(prev_batch: prev_batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_previous_batch', e)
    end
  end

  def set_feed_zone
    lambda do |p|
      return p unless p.code == 200

      feed_zone = FeedZone.create_or_find_by!(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      )

      raise "No FeedZone #{p.payload[:network]} #{p.payload[:batch_uuid]}" \
        if feed_zone.nil?

      Pipeline.new(200, p.payload.merge(feed_zone: feed_zone))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_feed_zone', e)
    end
  end

  def set_this_epoch
    lambda do |p|
      return p unless p.code == 200

      this_epoch = EpochHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).first

      Pipeline.new(200, p.payload.merge(this_epoch: this_epoch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_previous_batch', e)
    end
  end

  # Loop through all of the validators for this batch and complile the data.
  def compile_feed_zone_payload
    lambda do |p|
      return p unless p.code == 200

      p.payload[:feed_zone].payload_version = PAYLOAD_VERSION

      feed_zone_payload = []

      ValidatorHistory.where(
        network: p.payload[:network], batch_uuid: p.payload[:batch_uuid]
      ).each do |validator|
        tmp = {}

        # Basic batch & epoch data
        tmp['network'] = p.payload[:network]
        tmp['epoch'] = p.payload[:this_epoch].epoch
        tmp['batch_uuid'] = p.payload[:batch_uuid]
        tmp['batch_created_at'] = p.payload[:this_batch].created_at
        tmp['previous_batch_uuid'] = \
          if p.payload[:prev_batch].nil?
            nil
          else
            p.payload[:prev_batch].uuid
          end
        # validator_histories table
        tmp['validator_account'] = validator.account
        tmp['validator_delinquent'] = validator.delinquent
        tmp['validator_vote_account'] = validator.vote_account
        tmp['validator_commission'] = validator.commission
        tmp['validator_last_vote'] = validator.last_vote
        tmp['validator_root_block'] = validator.root_block
        tmp['validator_credits'] = validator.credits
        tmp['validator_active_stake'] = validator.active_stake

        # Calculate tower data
        # Highest root block
        tmp['tower_highest_block'] = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).maximum(:root_block)

        # Find the median root_block for this batch
        median_root = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).median(:root_block)
        # Calculate the median distance from the leader
        tmp['tower_cluster_median_behind_leader'] = \
          tmp['tower_highest_block'] - median_root

        # Find the average root_block for this batch
        average_root = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).average(:root_block)
        # Calculate the average distance from the leader
        tmp['tower_cluster_average_behind_leader'] = \
          tmp['tower_highest_block'] - average_root

        # Show this leader's distance behind the leader.
        tmp['tower_blocks_behind_leader'] = \
          if tmp['tower_highest_block'].nil?
            nil
          else
            tmp['tower_highest_block'] - validator.root_block
          end

        # Highest vote
        tmp['tower_highest_vote'] = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).maximum(:last_vote)

        # Find the median last_vote for this batch
        median_vote = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).median(:last_vote)
        # Calculate the median distance from the leader
        tmp['tower_cluster_median_vote_behind_leader'] = \
          tmp['tower_highest_vote'] - median_vote

        # Find the average root_block for this batch
        average_vote = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).average(:last_vote)
        # Calculate the average distance from the leader
        tmp['tower_cluster_average_vote_behind_leader'] = \
          tmp['tower_highest_vote'] - average_vote

        # Show this leader's distance behind the leader.
        tmp['tower_votes_behind_leader'] = \
          if tmp['tower_highest_vote'].nil?
            nil
          else
            tmp['tower_highest_vote'] - validator.last_vote
          end

        # If we have a Validator record, then append slot data
        validator2 = Validator.where(
          network: p.payload[:network], account: validator.account
        ).first
        if validator2
          # Look for the skipped slot data for this batch
          vbh = validator2.validator_block_histories.where(
            network: p.payload[:network],
            batch_uuid: p.payload[:batch_uuid]
          ).first
          if vbh
            # Set defaults to 0 if nil
            tmp['validator_epoch_leader_slots'] = vbh.leader_slots.to_i
            tmp['validator_epoch_blocks_produced'] = vbh.blocks_produced.to_i
            tmp['validator_epoch_skipped_slots'] = vbh.skipped_slots.to_i
            tmp['validator_epoch_skipped_slot_percent'] = \
              vbh.skipped_slot_percent.to_f
            tmp['validator_epoch_skipped_slots_after'] = \
              vbh.skipped_slots_after.to_i
            tmp['validator_epoch_skipped_slots_after_percent'] = \
              vbh.skipped_slots_after_percent.to_f
          end

          # Cluster Average Skipped Slot %
          # tmp['cluster_epoch_skipped_slot_percent_average'] = \
          #   validator2.validator_block_histories.where(
          #     network: p.payload[:network],
          #     batch_uuid: p.payload[:batch_uuid]
          #   ).average(:skipped_slot_percent).to_f

          # Cluster Median Skipped Slot %
          tmp['cluster_epoch_skipped_slot_percent_median'] = \
            ValidatorBlockHistory.where(
              network: p.payload[:network],
              batch_uuid: p.payload[:batch_uuid]
            ).median(:skipped_slot_percent).to_f

          # TODO: Look for the skipped stats for just this batch
          pvbh = validator2.validator_block_histories.where(
            network: p.payload[:network],
            batch_uuid: p.payload[:prev_batch].uuid
          ).first
          if vbh && pvbh
            tmp['validator_batch_leader_slots'] = \
              tmp['validator_epoch_leader_slots'] - pvbh.leader_slots.to_i

            tmp['validator_batch_blocks_produced'] = \
              tmp['validator_epoch_blocks_produced'] - pvbh.blocks_produced.to_i

            tmp['validator_batch_skipped_slots'] = \
              tmp['validator_epoch_skipped_slots'] - pvbh.skipped_slots.to_i

            tmp['validator_batch_skipped_slot_percent'] = \
              tmp['validator_batch_skipped_slots'] / tmp['validator_batch_leader_slots'].to_f

            tmp['validator_batch_skipped_slots_after'] = \
              tmp['validator_epoch_skipped_slots_after'] - pvbh.skipped_slots_after.to_i

            tmp['validator_batch_skipped_slots_after_percent'] = \
              tmp['validator_batch_skipped_slots_after'] /
              tmp['validator_batch_leader_slots'].to_f
          end

          # Look for the software_version in the vote_account_histories table
          vote_account = validator2.vote_accounts.where(
            account: validator.vote_account
          ).first
          if vote_account
            vah = vote_account.vote_account_histories.where(
              network: p.payload[:network],
              batch_uuid: p.payload[:batch_uuid]
            ).first
            tmp['software_version'] = vah.software_version if vah
          end
        end

        # If we have validator_block_history_stats
        vbhs = ValidatorBlockHistoryStat.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).first
        if vbhs
          tmp['cluster_epoch_start_slot'] = vbhs.start_slot
          tmp['cluster_epoch_end_slot'] = vbhs.end_slot
          tmp['cluster_epoch_total_slots'] = vbhs.total_slots
          tmp['cluster_epoch_total_blocks_produced'] = \
            vbhs.total_blocks_produced
          tmp['cluster_epoch_total_slots_skipped'] = vbhs.total_slots_skipped
          tmp['cluster_epoch_skipped_slot_percent'] = \
            tmp['cluster_epoch_total_slots_skipped'] / \
            tmp['cluster_epoch_total_slots'].to_f
        end

        # Ping Times Trailing 1_000 pings stats
        account_ping_times = PingTime.where(
          network: p.payload[:network],
          to_account: validator.account
        ).order('created_at desc').limit(1_000)

        tmp['ping_times_min_ms'] = account_ping_times.minimum(:min_ms)
        tmp['ping_times_avg_ms'] = account_ping_times.average(:avg_ms)
        tmp['ping_times_max_ms'] = account_ping_times.maximum(:max_ms)

        cluster_ping_times = PingTime.where(
          network: p.payload[:network]
        ).order('created_at desc').limit(1_000)

        tmp['ping_times_cluster_average_ms'] = \
          cluster_ping_times.average(:avg_ms)

        # TODO: Compile more data here.

        # Append tmp
        feed_zone_payload << tmp
      end

      Pipeline.new(200, p.payload.merge(feed_zone_payload: feed_zone_payload))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from compile_feed_zone_payload', e)
    end
  end

  def save_feed_zone
    lambda do |p|
      return p unless p.code == 200

      unless p.payload[:this_epoch].nil?
        p.payload[:feed_zone].epoch = p.payload[:this_epoch].epoch
      end

      p.payload[:feed_zone].payload_version = PAYLOAD_VERSION

      unless p.payload[:this_batch].nil?
        p.payload[:feed_zone].batch_created_at = \
          p.payload[:this_batch].created_at
      end
      p.payload[:feed_zone].payload = p.payload[:feed_zone_payload]
      p.payload[:feed_zone].save!

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_feed_zone', e)
    end
  end
end
