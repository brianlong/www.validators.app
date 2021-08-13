# frozen_string_literal: true

require 'test_helper'

# Query Objects for searching for ValidatorHistory relations and objects
class ValidatorHistoryQueryTest < ActiveSupport::TestCase
  def setup
    super

    network = 'testnet'
    batch_uuid = create(:batch).uuid
    @validator_history_query =
      ValidatorHistoryQuery.new(network, batch_uuid)

    @validator_histories = [
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 2, last_vote: 21, active_stake: 10),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 4, last_vote: 18, active_stake: 90),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 6, last_vote: 15, active_stake: 20),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 8, last_vote: 12, active_stake: 40),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 10, last_vote: 9, active_stake: 70),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 12, last_vote: 6, active_stake: 50),
      create(:validator_history, root_block: 14, last_vote: 3, active_stake: 30)
    ]

    @root_blocks = @validator_histories[0...-1].map(&:root_block)
    @last_votes = @validator_histories[0...-1].map(&:last_vote)
    @active_stakes = @validator_histories[0...-1].map(&:active_stake)
  end

  def teardown
    super

    @validator_histories.each(&:destroy)
  end

  test 'for_batch' do
    results = @validator_history_query.for_batch

    assert_equal results, @validator_histories.values_at(0, 1, 2, 3, 4, 5)
    assert_not_includes results, @validator_histories.last
  end
end
