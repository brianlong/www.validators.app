# frozen_string_literal: true

FactoryBot.define do
  factory :epoch_wall_clock do
    epoch { 123 }
    network { 'testnet' }
    starting_slot { 72_728_979 }
    slots_in_epoch { 432_000 }
  end
end
