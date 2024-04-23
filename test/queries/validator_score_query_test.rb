# frozen_string_literal: true

require 'test_helper'

# Query Objects for searching for ValidatorHistory relations and objects
class ValidatorScoreQueryTest < ActiveSupport::TestCase
  def setup
    batch_uuid = create(:batch).uuid
    validator_ids = []

    6.times do |n|
      v = create(:validator, :with_score, account: "validator_#{n}")
      validator_ids << v.id
    end

    @validators = Validator.where(id: validator_ids)

    @validators.map do |validator|
      create(
        :validator_history,
        batch_uuid: batch_uuid,
        account: validator.account,
        root_block: 2,
        last_vote: 21,
        active_stake: 10,
        network: "testnet",
        validator: validator
      )
    end

    @vsq = ValidatorScoreQuery.new("testnet", batch_uuid)
  end

  test 'for_batch' do
    expected = ValidatorScoreV1.where(validator_id: @validators.pluck(:id), network: "testnet")

    assert_equal expected.order(created_at: :asc).to_json, @vsq.for_batch.order(created_at: :asc).to_json
  end
end

