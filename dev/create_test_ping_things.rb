# frozen_string_literal: true

require File.expand_path("../config/environment", __dir__)

counts = [{count: 5000, min_time: 700,   max_time: 4500},
          {count: 1000, min_time: 4500,  max_time: 15000},
          {count: 500,  min_time: 15000, max_time: 25000},
          {count: 50,   min_time: 25000, max_time: 40000},
          {count: 5,    min_time: 40000, max_time: 100000}]

users = User.all.pluck(:id)

counts.each do |loop|
  loop[:count].times do |n|
    slot_sent = rand(10_000_000..100_000_000)
    p = PingThing.create(
      user_id: users.sample,
      amount: 1,
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjsdfsasdfasdfasdfasdfasdfdflkhasdlkhflkasjdhf6Rw#{n}",
      response_time: rand(loop[:min_time]..loop[:max_time]),
      transaction_type: "transfer",
      network: "mainnet",
      commitment_level: "confirmed",
      success: [true, false].sample,
      application: "web3",
      reported_at: rand(7.days.ago..Time.now),
      slot_sent: slot_sent,
      slot_landed: slot_sent + rand(100..10_000)
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

# Run rails r script/one_time_scripts/back_fill_ping_thing_stats.rb to create ping stats.
