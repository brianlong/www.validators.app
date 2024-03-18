#frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

pt_count = 0

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

loop do
  pt_count += 1

  slot_sent = rand(10_000_000..100_000_000)
  pt = PingThing.create(
    user_id: User.first.id,
    amount: 1,
    signature: SecureRandom.hex(32),
    response_time: rand(700..5_000),
    transaction_type: "transfer",
    network: "mainnet",
    commitment_level: "confirmed",
    success: true,
    application: "web3",
    reported_at: Time.now,
    slot_sent: slot_sent,
    slot_landed: slot_sent + rand(100..10_000)
  )

  if pt_count == 120
    puts "starting PingThingStatsWorker"
    PingThingStatsWorker.set(queue: :high_priority).perform_async
    pt_count = 0
  end

  break if interrupted
  sleep(0.5)
end
