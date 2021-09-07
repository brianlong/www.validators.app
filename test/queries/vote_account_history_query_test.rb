require 'test_helper'

class VoteAccountHistoryQueryTest < ActiveSupport::TestCase
  def setup
    super

    network = 'testnet'
    batch_uuid = create(:batch).uuid

    @vote_account_histories = [
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 1, credits_current: 140),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 2, credits_current: 120),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 4, credits_current: 100),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 8, credits_current: 80),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 16, credits_current: 60),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 32, credits_current: 40),
      create(:vote_account_history, slot_index_current: 64, credits_current: 220)
    ]

    @vahq = VoteAccountHistoryQuery.new(network, batch_uuid)
  end

  def teardown
    super

    @vote_account_histories.each(&:destroy)
  end

  test 'for_batch' do
    expected = @vote_account_histories[0...-1].to_a
    assert_equal expected, @vahq.for_batch
  end
end
