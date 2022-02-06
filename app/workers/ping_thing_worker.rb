class PingThingWorker
  include Sidekiq::Worker

  def perform(args = {})
    PingThingRaw.first(50).each do |raw|
      PingThing.create_from_raw(JSON.parse(raw.raw_data)) rescue nil
      raw.delete
    end
  end
end
