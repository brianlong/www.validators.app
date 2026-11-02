# frozen_string_literal: true

require 'test_helper'

class EpochWallClockTest < ActiveSupport::TestCase

  test 'all_by_network' do
    create(:epoch_wall_clock, epoch: 101)
    create(:epoch_wall_clock, epoch: 100)
    create(:epoch_wall_clock, epoch: 102)
    create(:epoch_wall_clock, epoch: 105, network: 'mainnet')

    assert_equal 3, EpochWallClock.by_network('testnet').count
    assert_equal 'testnet', EpochWallClock.by_network('testnet').last.network
  end

  test 'recent_finished skips current epoch and limits to EPOCHS_TO_CALCULATE by default' do
    (1..10).each { |epoch| create(:epoch_wall_clock, epoch: epoch, network: 'mainnet') }

    assert_equal [9, 8, 7], EpochWallClock.recent_finished('mainnet').pluck(:epoch)
  end

  test 'recent_finished returns ROD_EPOCHS_TO_CALCULATE epochs when limit is given' do
    (1..10).each { |epoch| create(:epoch_wall_clock, epoch: epoch, network: 'mainnet') }

    epochs = EpochWallClock.recent_finished('mainnet', EpochWallClock::ROD_EPOCHS_TO_CALCULATE).pluck(:epoch)

    assert_equal [9, 8, 7, 6, 5, 4, 3], epochs
  end
end
