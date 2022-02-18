# frozen_string_literal: true

class PingThingWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(args = {})
    ProcessPingThingsService.new(records_count: 100).call
  end
end
