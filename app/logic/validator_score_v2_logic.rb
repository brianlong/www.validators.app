# frozen_string_literal: true

# Logic to compile ValidatorScoreV2
module ValidatorScoreV2Logic
  include PipelineLogic

  # The constant below defines into how many groups we divide validators for scoring. The first group
  # will be assigned with score 0, the next one with +1, and so on, until we reach the limit of groups.
  NUMBER_OF_GROUPS = 3

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
      Pipeline.new(500, p.payload, "Error from set_this_batch", e)
    end
  end

  # Get all of the validators for this network + the validator_score_v2 records
  def validators_get
    lambda do |p|
      return p unless p.code == 200

      validators = Validator.where(network: p.payload[:network])
                            .active
                            .includes(:validator_score_v2)
                            .includes(:validator_score_v1)
                            .order(:id)
                            .all

      validators.each do |validator|
        # Make sure that we have a validator_score_v2 record for each validator
        if validator.validator_score_v2.nil?
          validator.create_validator_score_v2(network: p.payload[:network])
        end
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from validators_get", e)
    end
  end

  # Get the block vote history for each validator
  def set_validators_groups
    lambda do |p|
      return p unless p.code == 200

      validators_count_in_each_group = (p.payload[:validators].count/NUMBER_OF_GROUPS).ceil

      Pipeline.new(200, p.payload.merge(validators_count_in_each_group: validators_count_in_each_group))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from set_validators_groups", e)
    end
  end

  def assign_root_distance_scores
    lambda do |p|
      return p unless p.code == 200

      sorted_by_root_distance = p.payload[:validators].sort_by do |validator|
        validator.score.root_distance_history.to_a[-1].to_f
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      sorted_by_root_distance.reverse
                             .each_slice(p.payload[:validators_count_in_each_group])
                             .each_with_index do |group, index|
        group.each do |validator|
          validator.score_v2.root_distance_score = index
        end
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from assign_root_distance_scores", e)
    end
  end

  def assign_vote_distance_scores
    lambda do |p|
      return p unless p.code == 200

      sorted_by_vote_distance = p.payload[:validators].sort_by do |validator|
        validator.score.vote_distance_history.to_a[-1].to_f
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      sorted_by_vote_distance.reverse
                             .each_slice(p.payload[:validators_count_in_each_group])
                             .each_with_index do |group, index|
        group.each do |validator|
          validator.score_v2.vote_distance_score = index
        end
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from assign_vote_distance_scores", e)
    end
  end

  def assign_skipped_slot_score
    lambda do |p|
      return p unless p.code == 200

      sorted_by_skipped_slot = p.payload[:validators].sort_by do |validator|
        validator.score.skipped_slot_history.to_a[-1].to_f
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      sorted_by_skipped_slot.reverse
                            .each_slice(p.payload[:validators_count_in_each_group])
                            .each_with_index do |group, index|
        group.each do |validator|
          validator.score_v2.skipped_slot_score = index
        end
      rescue StandardError => e
        Appsignal.send_error(e)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from assign_skipped_slot_score", e)
    end
  end

  def save_validators
    lambda do |p|
      return p unless p.code == 200

      ActiveRecord::Base.transaction do
        p.payload[:validators].each do |validator|
          validator.save
          validator.score_v2.save
        rescue StandardError => e
          Appsignal.send_error(e)
        end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from save_validators", e)
    end
  end
end
