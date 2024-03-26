# frozen_string_literal: true

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
  end
end
