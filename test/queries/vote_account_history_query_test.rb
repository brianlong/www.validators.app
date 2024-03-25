require 'test_helper'

class VoteAccountHistoryQueryTest < ActiveSupport::TestCase
  def setup
    network = "testnet"
    batch_uuid = create(:batch).uuid
    v = create(:validator, network: network)
    va = create(:vote_account, network: network, validator: v)
    @vote_account_histories = [
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 1, credits_current: 140, vote_account: va),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 2, credits_current: 120, vote_account: va),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 4, credits_current: 100, vote_account: va),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 8, credits_current: 80, vote_account: va),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 16, credits_current: 60, vote_account: va),
      create(:vote_account_history, network: network, batch_uuid: batch_uuid,
                                    slot_index_current: 32, credits_current: 40, vote_account: va),
      create(:vote_account_history, slot_index_current: 64, credits_current: 220, vote_account: va)
    ]

    @vahq = VoteAccountHistoryQuery.new(network, batch_uuid)
  end

  test 'for_batch' do
    expected = @vote_account_histories[0...-1].to_a
    assert_equal expected, @vahq.for_batch
  end
end
