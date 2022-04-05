FactoryBot.define do
  factory :ping_thing_stat do
    interval { 1 }
    min { 1.5 }
    max { 1.5 }
    median { 1.5 }
    num_of_records { "" }
    network { "MyString" }
    time_from { "2022-04-05 12:00:27" }
  end
end
