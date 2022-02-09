class PingThingWorker
  include Sidekiq::Worker

  def perform(args = {})
    PingThingValidationService.new(records_count: 100).call
  end
end
