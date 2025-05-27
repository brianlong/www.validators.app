# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    vote_account { nil }
    last_vote { "" }
    root_slot { "" }
    credits { "" }
    activated_stake { "" }
  end
end
