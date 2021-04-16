# frozen_string_literal: true

require 'test_helper'

class ValidatorHistoryTest < ActiveSupport::TestCase
  setup do
    5.times do |i|
      create(
        :validator_history,
        last_vote: i,
        root_block: i,
        batch_uuid: '12345'
      )
    end
  end

  test 'average_root_block_distance_for' do
    assert_equal 2.0, ValidatorHistory.average_root_block_distance_for('testnet', '12345')
  end

  test 'average_root_block_distance_for returns 0 if no data' do
    assert_equal 0, ValidatorHistory.average_root_block_distance_for('testnet', '123456')
  end

  test 'average_last_vote_distance_for' do
    assert_equal 2, ValidatorHistory.average_last_vote_distance_for('testnet', '12345')
  end

  test 'average_last_vote_distance_for returns 0 if no data' do
    assert_equal 0, ValidatorHistory.average_last_vote_distance_for('testnet', '123456')
  end
end
