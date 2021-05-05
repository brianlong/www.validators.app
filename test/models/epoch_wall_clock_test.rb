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
end
