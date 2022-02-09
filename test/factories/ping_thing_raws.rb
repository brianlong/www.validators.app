FactoryBot.define do
  factory :ping_thing_raw do
    api_token { "api_token" }
    raw_data { 
      {
        amount: rand(1..100),
        time: rand(1..1000),
        signature: SecureRandom.hex(46),
        transaction_type: "transfer"
      }.to_json
    }
  end
end
