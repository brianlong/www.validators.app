FactoryBot.define do
  factory :slot do
    network { "MyString" }
    epoch { "" }
    slot_number { "" }
    leader_account { "MyString" }
    skipped { false }
    block_unix_time { "" }
    block_created_at { "2021-02-22 22:09:01" }
    commitment_level { "" }
  end
end
