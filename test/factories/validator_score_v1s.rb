# frozen_string_literal: true

FactoryBot.define do
  factory :validator_score_v1 do
    validator
    network { 'testnet' }
    delinquent { false }
    stake_concentration_score { 0 }
    data_center_concentration_score { 0 }
    total_score { 9 }
  end
end
