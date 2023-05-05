# frozen_string_literal: true

require 'test_helper'

class ValidatorCheckActiveWorkerTest < ActiveSupport::TestCase
  setup do
    create(:epoch_wall_clock, epoch: 123)
    @network = "testnet"
  end

  test 'validator with active stake and nondelinquent should be active' do
    v = create(:validator, :with_score, account: "account1")
    create(:validator_history, account: "account1")
    create(:validator_block_history, validator: v, epoch: 122)

    assert v.is_active

    ValidatorCheckActiveService.new.update_validator_activity

    assert v.reload.is_active
  end

  test 'validator with zero active stake should be inactive' do
    
    v = create(:validator, :with_score, account: "account2", network: @network)
    create(:validator_history, account: "account2", active_stake: 0, network: @network)
    create(:validator_history, account: "account2", active_stake: 0, network: @network, created_at: 13.hours.ago)

    assert v.is_active

    ValidatorCheckActiveService.new.update_validator_activity

    refute v.reload.is_active
  end

  test 'validator with zero active stake but too young should be active' do
    current_epoch = EpochWallClock.where(network: @network).order(created_at: :desc).first

    v = create(:validator, :with_score, account: "account3", network: @network)
    create(:validator_history, account: "account3", active_stake: 0, epoch: current_epoch.epoch, network: @network)

    assert v.is_active

    ValidatorCheckActiveService.new.update_validator_activity
    assert v.reload.is_active
  end

  test 'inactive validator with active stake should become active' do
    v = create(:validator, :with_score, account: "account4", is_active: false)
    create(:validator_history, account: "account4", active_stake: 1000, created_at: 2.days.ago)
    create(:validator_history, account: "account4", active_stake: 1000)

    refute v.is_active

    ValidatorCheckActiveService.new.update_validator_activity

    assert v.reload.is_active
  end

  test 'validator without vote_account should become rpc' do
    v = create(:validator, :with_score, account: "account4", created_at: 2.days.ago)
    create(:validator_history, account: "account4", active_stake: 1000)
    create(:validator_history, account: "account4", active_stake: 1000, created_at: 2.days.ago)
    refute v.is_rpc

    ValidatorCheckActiveService.new.update_validator_activity

    assert v.reload.is_rpc
  end

  test "validator delinquent for too long should be inactive" do
    v = create(:validator, :with_score, account: "account5")
    create(:validator_history, account: "account5", delinquent: true)
    create(:validator_block_history, validator: v, epoch: 122)
    create(:validator_history, account: "account5", delinquent: false, created_at: 25.hours.ago)
    create(:validator_block_history, validator: v, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    assert v.reload.is_active
  end

  test "validator with active stake but with delinquent state should be inactive" do
    validator = create(:validator, :delinquent, account: "account5", is_active: false)
    create(:validator_history, account: "account5", delinquent: true, active_stake: 10)
    create(:validator_block_history, validator: validator, epoch: 122)
    create(:validator_history, account: "account5", delinquent: false, created_at: 25.hours.ago)
    create(:validator_block_history, validator: validator, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    refute validator.reload.is_active
  end

  test "validator with no recent history should be marked as destroyed" do
    v = create(:validator, :with_score, account: "account6")
    create(:validator_history, account: "account6", created_at: 25.hours.ago)

    refute v.is_destroyed

    ValidatorCheckActiveService.new.update_validator_activity

    assert v.reload.is_destroyed
  end

  test "validator with recent history should not be marked as destroyed" do
    v = create(:validator, :with_score, account: "account7")
    create(:validator_history, account: "account7", created_at: 11.hours.ago)

    refute v.is_destroyed

    ValidatorCheckActiveService.new.update_validator_activity

    refute v.reload.is_destroyed
  end

  test "validator with recent history that is marked as destroyed should not be destroyed" do
    v = create(:validator, :with_score, account: "account7", is_destroyed: true)
    create(:validator_history, account: "account7", created_at: 11.hours.ago)
    create(:validator_history, account: "account7", created_at: 15.hours.ago)
    assert v.is_destroyed

    ValidatorCheckActiveService.new.update_validator_activity

    refute v.reload.is_destroyed
  end

  test "validator with acceptable_stake, not_delinquent and with vote_account"\
       "should have is_active: true, is_destroyed: false, is_rpc: false" do
    v = create(
      :validator, 
      :with_score, 
      account: "account7", 
      is_active: false, 
      is_destroyed: true, 
      is_rpc: true
    )
    create(:vote_account, validator: v)
    create(:validator_history, account: "account7", active_stake: 1000)
    create(:validator_history, account: "account7", created_at: 13.hours.ago)
    refute v.is_active
    assert v.is_destroyed
    assert v.is_rpc

    ValidatorCheckActiveService.new.update_validator_activity
    
    v.reload

    assert v.is_active
    refute v.is_destroyed
    refute v.is_rpc
  end
end
