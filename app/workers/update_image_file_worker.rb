# frozen_string_literal: true

class UpdateImageFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(args = {})
    validator = Validator.find(args["validator_id"])
    UpdateImageFileService.new(validator, :avatar).call
  end
end
