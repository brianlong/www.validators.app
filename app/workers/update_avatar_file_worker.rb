# frozen_string_literal: true

class UpdateAvatarFileWorker
  include Sidekiq::Worker

  def perform(args = {})
    validator = Validator.find(args["validator_id"])
    UpdateAvatarFileService.new(validator).call
  end
end
