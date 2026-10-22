# frozen_string_literal: true

require "test_helper"

class AlpenglowVoteRewardsServiceTest < ActiveSupport::TestCase
  SENTINEL = AlpenglowVoteRewardsService::EPOCH_CREDITS_SENTINEL

  setup do
    AlpenglowVoteRewardsService.leader_schedules.clear
    @service = AlpenglowVoteRewardsService.new(
      config_urls: ["http://127.0.0.1"],
      epoch: 1064,
      epoch_start_slot: 1_000_000,
      slot_index: 100
    )
    @inflation_state = { max_possible_validator_reward: 432_000_000, slots_per_epoch: 432_000, epoch: 1064 }
  end

  def account_info(*states, prev: nil)
    data = states.first.values_at(:max_possible_validator_reward, :slots_per_epoch, :epoch).pack("Q<Q<Q<")
    data += prev ? [1].pack("C") + prev.values_at(:max_possible_validator_reward, :slots_per_epoch, :epoch).pack("Q<Q<Q<") : [0].pack("C")
    { "value" => { "data" => [Base64.strict_encode64(data), "base64"] } }
  end

  def stub_rpc(service, responses, &block)
    service.stub(:rpc_request, ->(method, _params = []) { responses.fetch(method) }, &block)
  end

  test "#epoch_inflation_state decodes current epoch state" do
    stub_rpc(@service, "getAccountInfo" => account_info(@inflation_state)) do
      assert_equal @inflation_state, @service.epoch_inflation_state
    end
  end

  test "#epoch_inflation_state falls back to previous epoch state" do
    current = @inflation_state.merge(epoch: 1065, max_possible_validator_reward: 1)
    stub_rpc(@service, "getAccountInfo" => account_info(current, prev: @inflation_state)) do
      assert_equal @inflation_state, @service.epoch_inflation_state
    end
  end

  test "#epoch_inflation_state raises when epoch state is missing" do
    other = @inflation_state.merge(epoch: 1070)
    stub_rpc(@service, "getAccountInfo" => account_info(other)) do
      assert_raises(AlpenglowVoteRewardsService::EpochInflationStateMissing) { @service.epoch_inflation_state }
    end
  end

  test "#epoch_credits_current counts only alpenglow credits in migration epoch" do
    migrated = [[1063, 200, 100], [1064, 279, 200], [SENTINEL, SENTINEL, SENTINEL], [1064, 5_279, 279]]
    tower_only = [[1063, 200, 100], [1064, 279, 200]]

    assert_equal 5_000, @service.epoch_credits_current(migrated, true)
    assert_equal 0, @service.epoch_credits_current(tower_only, true)
  end

  test "#epoch_credits_current ignores entries from previous epochs" do
    assert_equal 0, @service.epoch_credits_current([[1063, 5_000, 0]], false)
    assert_equal 0, @service.epoch_credits_current([[1064, 79, 0], [SENTINEL, SENTINEL, SENTINEL]], true)
    assert_equal 0, @service.epoch_credits_current(nil, false)
    assert_equal 700, @service.epoch_credits_current([[1063, 5_000, 0], [1064, 5_700, 5_000]], false)
  end

  test "#max_credits adds voter and leader shares" do
    max_credits = @service.max_credits(
      @inflation_state, rewarded_slots: 100, leader_slots: 4, stake: 25, total_stake: 100
    )

    assert_equal 12_500 + 2_000, max_credits
  end

  test "#max_credits returns 0 without rewarded slots or stake" do
    assert_equal 0, @service.max_credits(@inflation_state, rewarded_slots: 0, leader_slots: 4, stake: 25, total_stake: 100)
    assert_equal 0, @service.max_credits(@inflation_state, rewarded_slots: 100, leader_slots: 4, stake: 0, total_stake: 100)
  end

  test "#leader_slots_count counts leader slots between migration and current slot index" do
    assert_equal 3, @service.leader_slots_count([10, 11, 50, 99, 100, 150], 11)
    assert_equal 0, @service.leader_slots_count(nil, 0)
  end

  test "#call sets credits and max credits from slots after migration" do
    vote_accounts = {
      "node1" => {
        "activated_stake" => 25,
        "credits_current" => 79,
        "epoch_credits" => [[1064, 79, 0], [SENTINEL, SENTINEL, SENTINEL], [1064, 1_079, 79]]
      },
      "node2" => {
        "activated_stake" => 75,
        "credits_current" => 79,
        "epoch_credits" => [[1064, 79, 0]]
      }
    }
    responses = {
      "getAccountInfo" => account_info(@inflation_state),
      "getAgGenesisCert" => { "block" => { "slot" => 1_000_039 } },
      "getLeaderSchedule" => { "node1" => [12, 40, 41, 99, 120], "node2" => [0, 1] }
    }

    result = stub_rpc(@service, responses) { @service.call(vote_accounts, 100) }

    assert_equal 1_000, result["node1"]["credits_current"]
    assert_equal 7_500 + 1_500, result["node1"]["max_credits_current"]
    assert_equal 0, result["node2"]["credits_current"]
    assert_equal 22_500, result["node2"]["max_credits_current"]
  end
end
