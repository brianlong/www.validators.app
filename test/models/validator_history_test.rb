# frozen_string_literal: true

require 'test_helper'

class ValidatorHistoryTest < ActiveSupport::TestCase
  def setup
    super
    @account = "account123"
    @network = 'testnet'

    @validator = create(:validator, account: @account, network: @network)
    @batch_uuid = create(:batch).uuid
  end

  test 'for_batch' do
    validator_histories = [
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 2,
                                 last_vote: 21, active_stake: 10),
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 4,
                                 last_vote: 18, active_stake: 90),
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 6,
                                 last_vote: 15, active_stake: 20),
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 8,
                                 last_vote: 12, active_stake: 40),
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 10,
                                 last_vote: 9, active_stake: 70),
      create(:validator_history, batch_uuid: @batch_uuid, root_block: 12,
                                 last_vote: 6, active_stake: 50),
      create(:validator_history, root_block: 14, last_vote: 3, active_stake: 30)
    ]

    results = ValidatorHistory.for_batch(@network, @batch_uuid)

    assert_equal results.order(created_at: :asc), validator_histories.values_at(0, 1, 2, 3, 4, 5)
    assert_not_includes results, validator_histories.last
  end

  test 'relationships belongs_to validator' do
    validator = create(:validator)
    validator_history = create(:validator_history,
                               account: validator.account,
                               validator: validator)

    assert_equal validator, validator_history.validator
  end

  test "scope #most_recent_epoch_credits_by_account returns most recent validator histories per account" do
    time = Date.today
    dates_with_epoch_credits = [[time - 2.day, 100],[time - 1.day, 200], [time, 300]]

    dates_with_epoch_credits.each do |arr|
      create(
        :validator_history,
        account: @validator.account,
        created_at: arr[0], 
        epoch_credits: arr[1],
        epoch: 222
      )
    end

    validator_histories_most_recent = ValidatorHistory.most_recent_epoch_credits_by_account
    validator_history = validator_histories_most_recent.find_by(account: @validator.account)

    assert_equal Validator.all.size, validator_histories_most_recent.size
    assert_equal @validator.account, validator_history.account
    assert_equal 300, validator_history.epoch_credits
    assert_equal 222, validator_history.epoch
    assert_equal time, validator_history.created_at
  end

  test "validator_histories_from_period returns number of records equal to given limit" do
    history_limit = 200

    210.times do |n|
      create(
        :validator_history,
        network: @network,
        account: @account,
        created_at: n.minutes.ago,
        validator: @validator
      )
    end

    result = ValidatorHistory.validator_histories_from_period(
      account: @validator.account,
      network: @network,
      from: 24.hours.ago,
      to: DateTime.now,
      limit: history_limit
    )
    assert_equal 200, result.count
  end

  test "validator_histories_from_period returns histories compliant with given criteria" do
    create(
      :validator_history,
      network: @network,
      account: @account,
      created_at: 20.hours.ago,
      validator: @validator
    )

    create(
      :validator_history,
      network: @network,
      account: @account,
      created_at: 25.hours.ago,
      validator: @validator
    )

    create(
      :validator_history,
      network: "mainnet",
      account: @account,
      created_at: 2.hours.ago,
      validator: @validator
    )

    result = ValidatorHistory.validator_histories_from_period(
      account: @validator.account,
      network: @network,
      from: 24.hours.ago,
      to: DateTime.now,
      limit: 100
    )

    assert_equal 1, result.count
    assert_equal @validator.network, result.last.network
    assert result.last.created_at > 24.hours.ago
  end
end
