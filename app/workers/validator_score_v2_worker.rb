# frozen_string_literal: true

class ValidatorScoreV2Worker
  include Sidekiq::Worker
  include ValidatorScoreV2Logic
  include PipelineLogic

  def perform(args = {})
    payload = {
      network: args["network"],
      batch_uuid: args["batch_uuid"]
    }

    _p = Pipeline.new(200, payload)
                 .then(&set_this_batch)
                 .then(&validators_get)
                 .then(&set_validators_groups)
                 .then(&assign_block_and_vote_scores)
                 .then(&assign_skipped_slot_score)
                 .then(&save_validators)
                 .then(&log_errors)
  end
end
