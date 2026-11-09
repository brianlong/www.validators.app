# frozen_string_literal: true

module XNotifications
  class DelinquencyWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed

    def perform(args = {})
      DelinquencyService.new(network: args["network"]).call
    end
  end
end
