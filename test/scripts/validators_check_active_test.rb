require 'test_helper'

class ValidatorCheckActiveTest < ActiveSupport::TestCase

  setup do
    create(:validator, :with_score, account: 'account1')
    create(:validator, :with_score, account: 'account2')
    create(:validator, :with_score, account: 'account3')
    create(:validator, :with_score, account: 'account4')

    11.times do
      create(:validator_history, account: 'account1')
      create(:validator_history, account: 'account2', delinquent: true)
      create(:validator_history, account: 'account3', active_stake: 0)
    end

    5.times do
      create(:validator_history, account: 'account4', delinquent: true)
    end

    load(Rails.root.join('script', 'validators_check_active.rb') )
  end

  test 'validator with active stake and nondelinquent should be active' do
    assert_equal true, Validator.find_by(account: 'account1').is_active
    assert_equal 2, Validator.scorable.where('account like ?', 'account%').count
  end

  test 'validator with zero active stake should be inactive' do
    assert_equal false, Validator.find_by(account: 'account3').is_active
  end

  test 'validator delinquent for too long should be inactive' do
    assert_equal false, Validator.find_by(account: 'account2').is_active
  end

  test 'validator with not enough validator_histories should be active' do
    assert_equal true, Validator.find_by(account: 'account4').is_active
  end
end