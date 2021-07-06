# frozen_string_literal: true

class ValidatorCheckActiveWorker
  include Sidekiq::Worker

  def perform
    ValidatorCheckActiveService.new.update_validator_activity
  end

end
