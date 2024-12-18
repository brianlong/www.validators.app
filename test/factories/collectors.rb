FactoryBot.define do
  factory :collector do
    user_id { 1 }
    payload_type { "ping_times" }
    payload_version { 1 }
    payload { [{
      user_id:1,
      network:"testnet",
      from_account:"ABCD",
      from_ip:"123.123.123.123",
      to_account:"EFGH",
      to_ip:"255.255.255.255",
      min_ms:0.881,
      avg_ms:1.238,
      max_ms:2.428,
      mdev:0.597
    },
    {
      user_id:1,
      network:"testnet",
      from_account:"ABCD",
      from_ip:"123.123.123.123",
      to_account:"IJKL",
      to_ip:"10.10.10.10",
      min_ms:1.881,
      avg_ms:2.238,
      max_ms:3.428,
      mdev:1.597
    }].to_json }
  end
end