# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

count = 10000

count.times do |n|
  p = PingThing.create(
    user_id: 1,
    amount: 1, signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjsdfsasdfasdfasdfasdfasdfdflkhasdlkhflkasjdhf6Rw#{n}",
    response_time: rand(10..(100 + n)),
    transaction_type: "margaryna",
    network: "testnet",
    commitment_level: "finalized",
    success: true,
    application: "mango",
    reported_at: Time.now - (n*4).seconds
  )
  if p.valid?
    puts p.inspect
    next
  else
    puts p.errors.full_messages
    break
  end
end