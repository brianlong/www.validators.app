# frozen_string_literal: true

require File.expand_path("../config/environment", __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

counts = [{count: 5000, min_time: 700,   max_time: 4000},
          {count: 1000, min_time: 4000,  max_time: 12000},
          {count: 500,  min_time: 12000, max_time: 20000},
          {count: 50,   min_time: 20000, max_time: 30000},
          {count: 5,    min_time: 30000, max_time: 100000}]

fees = [0, 100_000, 200_000, 300_000, 400_000, 500_000, 600_000, 700_000, 800_000, 900_000, 1_000_000]

users = User.all.pluck(:id)

counts.each do |loop|
  loop[:count].times do |n|
    slot_sent = rand(10_000_000..100_000_000)
    p = PingThing.create(
      user_id: users.sample,
      amount: 1,
      signature: SecureRandom.hex(32),
      response_time: rand(loop[:min_time]..loop[:max_time]),
      transaction_type: "transfer",
      network: "mainnet",
      commitment_level: "confirmed",
      success: [true, false].sample,
      application: "web3",
      reported_at: rand(5.minutes.ago..Time.now),
      slot_sent: slot_sent,
      slot_landed: slot_sent + rand(0..12),
      fee: fees[rand(0...fees.length)]
    )
    if p.valid?
      puts p.inspect
      next
    else
      puts p.errors.full_messages
      break
    end
  end
end

# Update recent stats
PingThingRecentStatsWorker.perform_async("mainnet")
PingThingUserStatsWorker.perform_async("mainnet")

# Run rails r script/one_time_scripts/back_fill_ping_thing_stats.rb to create ping stats.
