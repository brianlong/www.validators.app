# frozen_string_literal: true

require 'test_helper'

class ValidatorCheckActiveWorkerTest < ActiveSupport::TestCase
  setup do
    create(:epoch_wall_clock, epoch: 123)
  end

  test 'validator with active stake and nondelinquent should be active' do
    v = create(:validator, :with_score, account: 'account1')
    create(:validator_history, account: 'account1')
    create(:validator_block_history, validator: v, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    assert_equal true, Validator.find_by(account: 'account1').is_active
  end

  test 'validator with zero active stake should be inactive' do
    v = create(:validator, :with_score, account: 'account2')
    create(:validator_history, account: 'account2', active_stake: 0)
    create(:validator_block_history, validator: v, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    assert_equal false, Validator.find_by(account: 'account2').is_active
  end

  test 'validator with zero active stake but too young should be active' do
    v = create(:validator, :with_score, account: 'account3')
    create(:validator_history, account: 'account3', active_stake: 0)
    create(:validator_block_history, validator: v, epoch: 123)

    ValidatorCheckActiveService.new.update_validator_activity

    assert_equal true, Validator.find_by(account: 'account3').is_active
  end

  test 'inactive validator with active stake should become active' do
    v = create(:validator, :with_score, account: 'account4', is_active: false)
    create(:validator_history, account: 'account4', active_stake: 1000)
    create(:validator_block_history, validator: v, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    assert_equal true, Validator.find_by(account: 'account4').is_active
  end

  test 'validator delinquent for too long should be inactive' do
    v = create(:validator, :with_score, account: 'account5')
    create(:validator_history, account: 'account5', delinquent: true)
    create(:validator_block_history, validator: v, epoch: 122)

    ValidatorCheckActiveService.new.update_validator_activity

    assert_equal false, Validator.find_by(account: 'account5').is_active
  end

end
