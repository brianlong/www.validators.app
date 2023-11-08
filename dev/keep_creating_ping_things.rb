#frozen_string_literal: true

MIN_TIME = 700
MAX_TIME = 5_000

loop do
  slot_sent = rand(10_000_000..100_000_000)
  PingThing.create(
    user_id: User.first.id,
    amount: 1, 
    signature: SecureRandom.hex(16),
    response_time: rand(MIN_TIME..MAX_TIME),
    transaction_type: "transfer",
    network: "mainnet",
    commitment_level: "confirmed",
    success: true,
    application: "web3",
    reported_at: Time.now,
    slot_sent: slot_sent,
    slot_landed: slot_sent + rand(100..10_000)
  )
  sleep(0.5)
end
