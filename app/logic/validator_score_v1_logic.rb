# frozen_string_literal: true

# Logic to compile ValidatorScoreV1
module ValidatorScoreV1Logic
  include PipelineLogic

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

  # Get all of the validators for this network + the validator_score_v1 records
  def validators_get
    lambda do |p|
      return p unless p.code == 200

      validators = Validator.where(network: p.payload[:network])
                            .includes(:validator_score_v1)
                            .all

      # Make sure that we have a validator_score_v1 record for each validator
      validators.each do |validator|
        validator.create_validator_score_v1 if validator.validator_score_v1.nil?
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  # Get the block vote history for each validator
  def block_vote_history_get
    lambda do |p|
      return p unless p.code == 200

      # Grab the highest root block & vote for this batch so we can calculate
      # the distances
      highest_root = ValidatorHistory.highest_root_block_for(
        p.payload[:network],
        p.payload[:batch_uuid]
      )
      highest_vote = ValidatorHistory.highest_last_vote_for(
        p.payload[:network],
        p.payload[:batch_uuid]
      )

      p.payload[:validators].each do |validator|
        # Get the last root & vote for this validator
        # TODO: eliminate N+1 query
        vh = ValidatorHistory.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          account: validator.account
        ).first
        if vh
          root_distance = highest_root - vh.root_block.to_i
          vote_distance = highest_vote - vh.last_vote.to_i
          validator.validator_score_v1.commission = vh.commission
          validator.validator_score_v1.delinquent = vh.delinquent
          validator.validator_score_v1.active_stake = vh.active_stake
        else
          root_distance = highest_root
          vote_distance = highest_vote
        end
        validator.validator_score_v1.root_distance_history_push(root_distance)
        validator.validator_score_v1.vote_distance_history_push(vote_distance)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def assign_block_and_vote_scores
    lambda do |p|
      return p unless p.code == 200

      # get the average & median from the cluster history
      root_distance_all = []
      vote_distance_all = []
      p.payload[:validators].each do |v|
        root_distance_all += v.validator_score_v1.root_distance_history
        vote_distance_all += v.validator_score_v1.vote_distance_history
      end
      root_distance_all_average = array_average(root_distance_all)
      root_distance_all_median = array_median(root_distance_all)
      vote_distance_all_average = array_average(vote_distance_all)
      vote_distance_all_median = array_median(vote_distance_all)

      p.payload[:validators].each do |v|
        # Assign the root_distance_score
        avg_root_distance = v.validator_score_v1.avg_root_distance_history
        v.validator_score_v1.root_distance_score = \
          if avg_root_distance <= root_distance_all_median
            2
          elsif avg_root_distance <= root_distance_all_average
            1
          else
            0
          end

        # Assign the vote distance score
        avg_vote_distance = v.validator_score_v1.avg_vote_distance_history
        v.validator_score_v1.vote_distance_score = \
          if avg_vote_distance <= vote_distance_all_median
            2
          elsif avg_vote_distance <= vote_distance_all_average
            1
          else
            0
          end
      end

      Pipeline.new(200, p.payload.merge(
                          root_distance_all: root_distance_all,
                          vote_distance_all: vote_distance_all,
                          root_distance_all_average: root_distance_all_average,
                          root_distance_all_median: root_distance_all_median,
                          vote_distance_all_average: vote_distance_all_average,
                          vote_distance_all_median: vote_distance_all_median
                        ))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  # Get the data for skipped slot % & skipped after %
  def block_history_get
    lambda do |p|
      return p unless p.code == 200

      # byebug
      avg_skipped_slot_pct_all = \
        ValidatorBlockHistory.average_skipped_slot_percent_for(
          p.payload[:network],
          p.payload[:batch_uuid]
        )
      med_skipped_slot_pct_all = \
        ValidatorBlockHistory.median_skipped_slot_percent_for(
          p.payload[:network],
          p.payload[:batch_uuid]
        )

      avg_skipped_after_pct_all = \
        ValidatorBlockHistory.average_skipped_slots_after_percent_for(
          p.payload[:network],
          p.payload[:batch_uuid]
        )
      med_skipped_after_pct_all = \
        ValidatorBlockHistory.median_skipped_slots_after_percent_for(
          p.payload[:network],
          p.payload[:batch_uuid]
        )

      p.payload[:validators].each do |validator|
        vbh = validator.validator_block_histories.where(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid]
        ).first
        next unless vbh

        validator.validator_score_v1.skipped_slot_history_push(
          vbh.skipped_slot_percent.to_f
        )
        validator.validator_score_v1.skipped_after_history_push(
          vbh.skipped_slots_after_percent.to_f
        )
      end

      Pipeline.new(
        200,
        p.payload.merge(
          avg_skipped_slot_pct_all: avg_skipped_slot_pct_all,
          med_skipped_slot_pct_all: med_skipped_slot_pct_all,
          avg_skipped_after_pct_all: avg_skipped_after_pct_all,
          med_skipped_after_pct_all: med_skipped_after_pct_all
        )
      )
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def assign_block_history_score
    lambda do |p|
      return p unless p.code == 200

      p.payload[:validators].each do |validator|
        skipped_slot_percent = \
          validator&.validator_score_v1&.skipped_slot_history&.last
        skipped_after_percent = \
          validator&.validator_score_v1&.skipped_after_history&.last

        # Assign the scores
        validator.validator_score_v1.skipped_slot_score = \
          if skipped_slot_percent.nil?
            0
          elsif skipped_slot_percent <= p.payload[:med_skipped_slot_pct_all]
            2
          elsif skipped_slot_percent <= p.payload[:avg_skipped_slot_pct_all]
            1
          else
            0
          end
        validator.validator_score_v1.skipped_after_score = \
          if skipped_after_percent.nil?
            0
          elsif skipped_after_percent <= p.payload[:med_skipped_after_pct_all]
            2
          elsif skipped_after_percent <= p.payload[:avg_skipped_after_pct_all]
            1
          else
            0
          end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def assign_software_version_score
    lambda do |p|
      return p unless p.code == 200

      p.payload[:validators].each do |validator|
        vah = validator&.vote_accounts&.last&.vote_account_histories&.last
        if vah
          unless vah.software_version.blank?
            validator.validator_score_v1.software_version = \
              vah.software_version
          end
        end
        validator.validator_score_v1.assign_software_version_score
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def get_ping_times
    lambda do |p|
      return p unless p.code == 200

      p.payload[:validators].each do |validator|
        # Ping Times Trailing 100 pings stats.
        # Do not use ActiveRecord to calculate the averages! Horrible
        # performance
        account_ping_times = PingTime.where(
          network: p.payload[:network],
          to_account: validator.account
        ).order('created_at desc').limit(100)

        account_avg_ms = account_ping_times.map { |pt| pt.avg_ms.to_f.round(2) }

        validator.validator_score_v1.ping_time_avg = \
          if account_avg_ms.empty?
            nil
          else
            account_avg_ms.sum / account_avg_ms.size.to_f
          end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def save_validators
    lambda do |p|
      return p unless p.code == 200

      ActiveRecord::Base.transaction do
        p.payload[:validators].each do |validator|
          validator.save!
          validator.validator_score_v1.save!
        end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end
end
