require 'test_helper'
require 'sidekiq/testing'

class ValidatorCheckActiveWorkerTest < ActiveSupport::TestCase
  setup do
    create(:epoch_wall_clock, epoch: 125)
  end

  test 'worker should be performed as expected' do
    v = create(:validator, :with_score, account: 'account1')
    create(:validator_history, account: "account1", validator: v)
    create(:validator_block_history, validator: v, epoch: 124)

    Sidekiq::Testing.inline! do
      ValidatorCheckActiveWorker.perform_async

      assert v.reload.is_active
    end
  end
end
