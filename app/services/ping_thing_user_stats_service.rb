#frozen_string_literal: true

class PingThingUserStatsService

  def initialize(network: "mainnet", interval: 5)
    @network = network
    @interval = interval
    @ping_things = []
    @stats = []
  end

  def call
    gather_ping_things
    delete_old_stats
    pt_by_user.each do |user_id, user_ping_things|
      next if user_ping_things.map(&:success).count(true) == 0
      
      ping_times = user_ping_things.pluck(:response_time).compact.sort
      username = User.find(user_id).username

      pts = PingThingUserStat.find_or_create_by(
        user_id: user_id,
        interval: @interval,
        network: @network
      )
      slot_latency_stats = PingThing.slot_latency_stats(records: user_ping_things)
      pts.update(
        username: username,
        median: ping_times.median,
        min: ping_times.min,
        max: ping_times.max,
        p90: ping_times.first((ping_times.count * 0.9).round).last,
        num_of_records: ping_times.count,
        min_slot_latency: slot_latency_stats[:min],
        average_slot_latency: slot_latency_stats[:median],
        p90_slot_latency: slot_latency_stats[:p90],
        fails_count: user_ping_things.map(&:success).count(false)
      )

      @stats << pts
    end

    broadcast
  end

  def delete_old_stats
    PingThingUserStat.where(network: @network, interval: @interval)
                     .where('updated_at < ?', @interval.minutes.ago)
                     .destroy_all
  end

  def gather_ping_things
    @ping_things = PingThing.for_reported_at_range_and_network(
      @network,
      @interval.minutes.ago,
      Time.now
    )
  end

  def pt_by_user
    @ping_things.group_by(&:user_id)
  end
end

def broadcast
  data = {
    network: @network,
    interval: @interval,
    stats: @stats.group_by(&:username)
  }
  ActionCable.server.broadcast("ping_thing_user_stat_channel", data.to_json)
end
