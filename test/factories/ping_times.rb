FactoryBot.define do
  factory :ping_time do
    batch_id { "MyString" }
    network { "MyString" }
    from_account { "MyString" }
    from_ip { "MyString" }
    to_account { "MyString" }
    to_ip { "MyString" }
    min_ms { "9.99" }
    avg_ms { "9.99" }
    max_ms { "9.99" }
    mdev { "9.99" }
  end
end
