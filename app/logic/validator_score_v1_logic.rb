# frozen_string_literal: true

# Logic to compile ValidatorScoreV1
module ValidatorScoreV1Logic
  include PipelineLogic
  STAKE_CONCENTRATION_FACTOR = 0.03

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
                            .order(:id)
                            .all

      # Make sure that we have a validator_score_v1 record for each validator
      validators.each do |validator|
        validator.create_validator_score_v1 if validator.validator_score_v1.nil?
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_get', e)
    end
  end

  # Get the block vote history for each validator
  def block_vote_history_get
    lambda do |p|
      return p unless p.code == 200

      # Grab the highest root block & vote for this batch so we can calculate
      # the distances
      #
      # NOTE: We are hitting the database three times for these three stats.
      # Will it be faster to load the batch into memory and perform the
      # calculations in RAM? We could also eliminate the N+1 query a little
      # further below if we have the batch in RAM.
      highest_root = ValidatorHistory.highest_root_block_for(
        p.payload[:network],
        p.payload[:batch_uuid]
      )
      highest_vote = ValidatorHistory.highest_last_vote_for(
        p.payload[:network],
        p.payload[:batch_uuid]
      )
      total_active_stake = ValidatorHistory.total_active_stake_for(
        p.payload[:network],
        p.payload[:batch_uuid]
      )

      # The to_a at the end ensures that the query is run here, instead of
      # inside of the `p.payload[:validators].each` block which eliminates an
      # N+1 query
      validator_histories = ValidatorHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).where({ account: p.payload[:validators].map(&:account) }).to_a

      p.payload[:validators].each do |validator|
        # Get the last root & vote for this validator
        vh = validator_histories.select { |vh| vh.account == validator.account }.first

        if vh
          root_distance = highest_root - vh.root_block.to_i
          vote_distance = highest_vote - vh.last_vote.to_i
          unless vh.commission.nil?
            validator.validator_score_v1.commission = vh.commission
          end
          unless vh.delinquent.nil?
            validator.validator_score_v1.delinquent = vh.delinquent
          end
          unless vh.active_stake.nil?
            validator.validator_score_v1.active_stake = vh.active_stake
          end
          validator.validator_score_v1.stake_concentration = \
            (vh.active_stake.to_f / total_active_stake.to_f)
        else
          root_distance = highest_root
          vote_distance = highest_vote
        end

        validator.validator_score_v1.root_distance_history_push(root_distance)
        validator.validator_score_v1.vote_distance_history_push(vote_distance)
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload.merge(total_active_stake: total_active_stake))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from block_vote_history_get', e)
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
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      root_distance_all_average = array_average(root_distance_all)
      root_distance_all_median = array_median(root_distance_all)
      vote_distance_all_average = array_average(vote_distance_all)
      vote_distance_all_median = array_median(vote_distance_all)

      Rails.logger.warn "#{p.payload[:network]} root_distance_all_average: #{root_distance_all_average}"
      Rails.logger.warn "#{p.payload[:network]} root_distance_all_median: #{root_distance_all_median}"
      Rails.logger.warn "#{p.payload[:network]} vote_distance_all_average: #{vote_distance_all_average}"
      Rails.logger.warn "#{p.payload[:network]} vote_distance_all_median: #{vote_distance_all_median}"

      p.payload[:validators].each do |v|
        # Assign the root_distance_score
        avg_root_distance = v.validator_score_v1.avg_root_distance_history
        med_root_distance = v.validator_score_v1.med_root_distance_history

        Rails.logger.warn "#{p.payload[:network]} #{v.account} avg_root_distance: #{avg_root_distance}, med_root_distance: #{med_root_distance}"

        v.validator_score_v1.root_distance_score = \
          if med_root_distance <= root_distance_all_median
            2
          elsif avg_root_distance <= root_distance_all_average
            1
          else
            0
          end

        # Assign the vote distance score
        avg_vote_distance = v.validator_score_v1.avg_vote_distance_history
        med_vote_distance = v.validator_score_v1.med_vote_distance_history

        v.validator_score_v1.vote_distance_score = \
          if med_vote_distance <= vote_distance_all_median
            2
          elsif avg_vote_distance <= vote_distance_all_average
            1
          else
            0
          end

        # Assign the stake concentration & score
        v.validator_score_v1.stake_concentration_score = \
          if v.validator_score_v1.stake_concentration.to_f >= (STAKE_CONCENTRATION_FACTOR * 2)
            -2
          elsif v.validator_score_v1.stake_concentration.to_f >= STAKE_CONCENTRATION_FACTOR
            -1
          else
            0
          end
      rescue StandardError => e
        Appsignal.send_error(e)
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
      Pipeline.new(500, p.payload, 'Error from assign_block_and_vote_scores', e)
    end
  end

  # Get the data for skipped slot %
  def block_history_get
    lambda do |p|
      return p unless p.code == 200

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

      sql = <<-SQL_END
        SELECT vbh.validator_id, vbh.skipped_slot_percent
        FROM validator_block_histories vbh
        WHERE vbh.network = '#{p.payload[:network]}' AND vbh.batch_uuid = '#{p.payload[:batch_uuid]}'
      SQL_END

      skipped_slot_percents = ActiveRecord::Base.connection.execute(sql).to_a

      p.payload[:validators].each do |validator|
        last_validator_block_history_for_validator = skipped_slot_percents.find { |r| r.first == validator.id }

        next unless last_validator_block_history_for_validator.present?
        skipped_slot_percent = last_validator_block_history_for_validator.last

        validator.validator_score_v1.skipped_slot_history_push(
          skipped_slot_percent.to_f
        )
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(
        200,
        p.payload.merge(
          avg_skipped_slot_pct_all: avg_skipped_slot_pct_all,
          med_skipped_slot_pct_all: med_skipped_slot_pct_all
        )
      )
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from block_history_get', e)
    end
  end

  def assign_block_history_score
    lambda do |p|
      return p unless p.code == 200

      p.payload[:validators].each do |validator|
        skipped_slot_percent = \
          validator&.validator_score_v1&.skipped_slot_history&.last

        # Assign the scores
        validator.validator_score_v1.skipped_slot_score = \
          if skipped_slot_percent.nil?
            0
          elsif skipped_slot_percent.to_f <= p.payload[:med_skipped_slot_pct_all].to_f
            2
          elsif skipped_slot_percent.to_f <= p.payload[:avg_skipped_slot_pct_all].to_f
            1
          else
            0
          end
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from assign_block_history_score', e)
    end
  end

  def assign_software_version_score
    lambda do |p|
      return p unless p.code == 200

      # call #to_a at the end to guarantee the query is run now, instead of inside of the loop
      last_validator_histories = ValidatorHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).to_a

      p.payload[:validators].each do |validator|
        vah = last_validator_histories.find { |vh| vh.account == validator.account }

        if vah.nil?
          Rails.logger.warn "Making_n_plus_one_query"
          vah = validator&.vote_accounts&.last&.vote_account_histories&.last
        end
        # This means we skip the software version for non-voting nodes.
        if vah
          if vah.software_version.present? && ValidatorSoftwareVersion.valid_software_version?(vah.software_version)
            validator.validator_score_v1.software_version = vah.software_version
          end
        end
        validator.validator_score_v1.assign_software_version_score
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from assign_software_version_score', e)
    end
  end

  def get_ping_times
    lambda do |p|
      return p unless p.code == 200

      p.payload[:validators].each do |validator|
        validator.validator_score_v1.ping_time_avg = \
          validator.ping_times_to_avg
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_ping_times', e)
    end
  end

  def save_validators
    lambda do |p|
      return p unless p.code == 200

      ActiveRecord::Base.transaction do
        p.payload[:validators].each do |validator|
          validator.save
          validator.validator_score_v1.save
        rescue StandardError => e
          Appsignal.send_error(e)
        end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_validators', e)
    end
  end
end
