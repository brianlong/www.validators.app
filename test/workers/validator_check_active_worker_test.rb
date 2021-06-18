require 'test_helper'
require 'sidekiq/testing'

class ValidatorCheckActiveTest < ActiveSupport::TestCase
  test 'validator with active stake and nondelinquent should be active' do
    create(:validator, :with_score, account: 'account1')
    11.times do
      create(:validator_history, account: 'account1')
    end

    Sidekiq::Testing.inline! do
      ValidatorCheckActiveWorker.perform_async

      assert_equal true, Validator.find_by(account: 'account1').is_active
    end
  end

  test 'validator with zero active stake should be inactive' do
    create(:validator, :with_score, account: 'account3')
    11.times do
      create(:validator_history, account: 'account3', active_stake: 0)
    end

    Sidekiq::Testing.inline! do
      ValidatorCheckActiveWorker.perform_async

      assert_equal false, Validator.find_by(account: 'account3').is_active
    end
  end

  test 'validator delinquent for too long should be inactive' do
    create(:validator, :with_score, account: 'account2')
    11.times do
      create(:validator_history, account: 'account2', delinquent: true)
    end

    Sidekiq::Testing.inline! do
      ValidatorCheckActiveWorker.perform_async

      assert_equal false, Validator.find_by(account: 'account2').is_active
    end
  end

  test 'validator with not enough validator_histories should be active' do
    create(:validator, :with_score, account: 'account4')
    5.times do
      create(:validator_history, account: 'account4', delinquent: true)
    end

    Sidekiq::Testing.inline! do
      ValidatorCheckActiveWorker.perform_async

      assert_equal true, Validator.find_by(account: 'account4').is_active
    end
  end
end
