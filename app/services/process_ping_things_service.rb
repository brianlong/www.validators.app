# frozen_string_literal: true

class ProcessPingThingsService

  def initialize(records_count: 100)
    @records_count = records_count
  end

  def call
    records_to_process.each do |raw|
      params = raw.attributes_from_raw
      user = User.find_by(api_token: raw.api_token)

      params.merge!(
        user: user,
        network: raw.network,
        created_at: raw.created_at
      )
      ping_thing = PingThing.new(params)

      # create sidekiq job to update stats if it's not a latest data
      if ping_thing.save && raw.should_recalculate_stats_after_processing?
        RecalculatePingThingStatsWorker.perform_async({
          "reported_at" => ping_thing.reported_at,
          "network" => ping_thing.network
        })
      end

      raw.delete

    # in case of passing wrong commitment_level, which is an enum
    # that raises an ArgumentError when wrong value is assigned
    rescue ArgumentError => e
      raw.delete
      next
    end

    true
  end

  private

  def records_to_process
    PingThingRaw.first(@records_count)
  end
end
