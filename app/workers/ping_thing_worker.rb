class PingThingWorker
  include Sidekiq::Worker

  def perform(args = {})
    ProcessPingThingsService.new(records_count: 100).call
  end
end
