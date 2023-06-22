# frozen_string_literal: true

class CheckGroupValidatorAssignmentWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(args = {})
    CheckGroupValidatorAssignmentService.new(vote_account_id: args["vote_account_id"]).call
  end
end
