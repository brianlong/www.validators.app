class PingThingFeeStatsService

  def initialize(network: @network)
    @network = network
  end

  def call
    ping_things = PingThing.where(network: @network).where('reported_at > ?', PingThingFeeStat::INTERVAL.ago)
    puts ping_things.count
    ping_things.pluck(:priority_fee_percentile).compact.uniq.each do |fee|
      ping_things_by_fee = ping_things.where(priority_fee_percentile: fee)
      ping_things_by_fee.pluck(:pinger_region).compact.uniq.each do |region|
        ping_things_by_fee_and_region = ping_things_by_fee.where(pinger_region: region)
        next if PingThingFeeStat.where('created_at > ?', PingThingFeeStat::INTERVAL.ago - 5.minutes).where(priority_fee_percentile: fee, network: @network, pinger_region: region).exists?

        slot_latency_stats = PingThing.slot_latency_stats(records: ping_things_by_fee_and_region)
        time_stats = PingThing.time_stats(records: ping_things_by_fee_and_region)
        PingThingFeeStat.create(
          priority_fee_percentile: fee,
          priority_fee_micro_lamports_average: ping_things_by_fee_and_region.average(:priority_fee_micro_lamports),
          network: @network,
          pinger_region: region,
          min_time: time_stats[:min],
          median_time: time_stats[:median],
          p90_time: time_stats[:p90],
          min_slot_latency: slot_latency_stats[:min],
          median_slot_latency: slot_latency_stats[:median],
          p90_slot_latency: slot_latency_stats[:p90],
          average_time: ping_things_by_fee_and_region.average(:response_time)
        )
      end
    end
  end
end