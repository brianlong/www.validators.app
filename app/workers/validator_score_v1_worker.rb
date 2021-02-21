# frozen_string_literal: true

class ValidatorScoreV1Worker
  include Sidekiq::Worker
  include ValidatorScoreV1Logic
  include PipelineLogic

  def perform(args = {})
    payload = {
      network: args['network'],
      batch_uuid: args['batch_uuid']
    }

    _p = Pipeline.new(200, payload)
                 .then(&set_this_batch)
                 .then(&validators_get)
                 .then(&block_vote_history_get)
                 .then(&assign_block_and_vote_scores)
                 .then(&block_history_get)
                 .then(&assign_block_history_score)
                 .then(&assign_software_version_score)
                 .then(&save_validators)
                 .then(&log_errors)

    # .then(&get_ping_times) was after assign_software_version_score
  end
end
