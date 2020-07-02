# frozen_string_literal: true

FactoryBot.define do
  factory :ping_time_stat do
    batch_uuid { 'MyString' }
    overall_min_time { '9.99' }
    overall_max_time { '9.99' }
    overall_average_time { '9.99' }
  end
end
