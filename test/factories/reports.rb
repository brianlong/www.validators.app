FactoryBot.define do
  factory :report do
    batch_uuid { SecureRandom.uuid }
    network { 'testnet' }

    trait :build_skipped_slot_percent do
      name { 'build_skipped_slot_percent' }
      payload do
        [
          {
            'account' => 'Test Account',
            'skipped_slots' => 'skipped_slots',
            'skipped_slot_percent' => 'skipped_slot_percent',
            'validator_id' => nil,
            'ping_time' => nil
          }
        ]
      end
    end

    trait :report_cluster_stats do
      name { "report_cluster_stats" }
      payload do
        {
          "root_distance" => {
            "max": 1111,
            "min": 22222,
            "median": 3333,
            "average": 44444
          },
          "vote_distance" => {
            "max": 5555,
            "min": 666,
            "median": 777,
            "average": 888
          },
          "skipped_slots" => {
            "max": "111",
            "min": "2222",
            "median": "333",
            "average": "4444"
          },
          "skipped_votes_percent" => {
            "max": 5555,
            "min": 6666,
            "best": 777,
            "median": 8888,
            "average": 999
          }
        }
      end
    end
  end
end
