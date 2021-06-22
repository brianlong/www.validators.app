# frozen_string_literal: true

require 'test_helper'

class AddCurrentEpochScriptTest < ActiveSupport::TestCase
  test 'script when no current epoch should add epoch to db' do
    VCR.use_cassette(
      'add_current_epoch_script/no_previous_epochs',
      record: :new_episodes
    ) do
      load(Rails.root.join('script', 'add_current_epoch.rb'))

      assert_equal 2, EpochWallClock.count
      assert_equal 200, EpochWallClock.last.epoch
      assert_equal 432000, EpochWallClock.last.slots_in_epoch
      assert_nil EpochWallClock.last.ending_slot
    end
  end

  test 'script when there are some epochs should also update previous epoch' do
    create(:epoch_wall_clock, epoch: 199, network: 'testnet')
    create(:epoch_wall_clock, epoch: 199, network: 'mainnet')

    VCR.use_cassette(
      'add_current_epoch_script/with_previous_epochs',
      record: :new_episodes
    ) do
      load(Rails.root.join('script', 'add_current_epoch.rb') )

      assert_equal 808_762_55, EpochWallClock.where(epoch: 199, network: 'testnet')
                                             .last
                                             .ending_slot
    end
  end
end
