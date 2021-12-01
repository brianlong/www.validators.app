require 'test_helper'

class ClusterStatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ReportLogic

  setup do
    @user = create(:user)
  end

  test 'Cluster Stats Index shows proper data for testnet' do
    data = prepare_data_for_cluster_stats('testnet')
    generate_report("testnet")
    sign_in @user
    get cluster_stats_url(network: 'testnet')

    assert_response :success
    assert_data_for('testnet', data)
  end

  test 'Cluster Stats Index shows proper data for mainnet' do
    data = prepare_data_for_cluster_stats('mainnet')
    generate_report("mainnet")
    sign_in @user
    get cluster_stats_url(network: 'mainnet')

    assert_response :success
    assert_data_for('mainnet', data)
  end

  private

  def generate_report(network)
    payload = {
      network: network,
      batch_uuid: Batch.where(network: network).last.uuid
    }
    
    p = Pipeline.new(200, payload)
                 .then(&report_cluster_stats)
  end

  def assert_data_for(network, data)
    stats = assigns :stats

    top_staked_validators =
      data[:validators].map { |v| v.validator_score_v1.active_stake }
                       .sort.reverse
    top_skipped_vote_validators =
      data[:vote_account_histories].map(&:skipped_vote_percent_moving_average)
                                   .sort.reverse

    top_root_distance_validators =
      data[:validators].map { |v| v.validator_score_v1.root_distance_history }
                       .map(&:average).sort.reverse

    top_vote_distance_averages_validators =
      data[:validators].map { |v| v.validator_score_v1.vote_distance_history }
                       .map(&:average).sort.reverse

    top_skipped_slot_percent =
      data[:validator_block_histories].map(&:skipped_slot_percent_moving_average)
                                      .sort.reverse
    skipped_votes_stats =
      { min: 0.3518806943896684, max: 0.3518806943896684, median: 0.3518806943896684,
        average: 0.35188069438966835, best: 0.3518806943896684 }
    skipped_vote_moving_average_stats =
      { min: 0.3519e0.to_s, max: 0.3519e0.to_s, median: 0.3519e0.to_s, average: 0.3519e0.to_s}

    # root_distance_history, vote_distance_stats for each factored validator
    # is [1,2,3,4,5] and we use averages (which equals to 3) of root
    # distance for statistics
    root_distance_stats = { min: 3, max: 3, median: 3, average: 3 }
    vote_distance_stats = { min: 3, max: 3, median: 3, average: 3 }
    skipped_slot_stats = { min: 0.25.to_s, max: 0.25.to_s, median: 0.25.to_s, average: 0.25.to_s }


    assert_equal stats[:batch_uuid], Batch.last_scored(network).uuid
    assert_equal top_staked_validators, stats[:top_staked_validators].map(&:first), 'Top Staked Validators'
    assert_equal top_skipped_vote_validators.map(&:to_s), stats[:top_skipped_vote_validators].map(&:first), "Top Skipped Vote"
    assert_equal top_root_distance_validators, stats[:top_root_distance_validators].map(&:first), 'Top Root Distance'
    assert_equal top_vote_distance_averages_validators, stats[:top_vote_distance_validators].map(&:first), 'Top Vote Distance'
    assert_equal top_skipped_slot_percent.map(&:to_s), stats[:top_skipped_slot_validators].map(&:first), "Top Skipped Slot"
    assert_equal skipped_votes_stats, stats[:skipped_votes_percent], 'Skipped Vote Stats'
    assert_equal skipped_vote_moving_average_stats, stats[:skipped_votes_percent_moving_average] , 'skipped_vote_moving_average_stats'
    assert_equal root_distance_stats, stats[:root_distance], 'root_distance_stats'
    assert_equal vote_distance_stats, stats[:vote_distance], 'vote_distance_stats'
    assert_equal skipped_slot_stats, stats[:skipped_slots], 'skipped_slot_stats'
  end

  def prepare_data_for_cluster_stats(network)
    batch = create :batch, network: network

    validators = create_list :validator, 10, :with_score, network: network
    validator_histories = validators.map do |validator|
      create :validator_history, batch_uuid: batch.uuid,
                                 network: network,
                                 account: validator.account
    end

    vote_accounts = validators.map do |validator|
      create :vote_account, validator: validator, network: network
    end

    vote_account_histories = vote_accounts.map do |vote_account|
      create_list :vote_account_history, 3,
                  network: network,
                  batch_uuid: batch.uuid,
                  vote_account: vote_account
    end.flatten

    validator_block_histories = validators.map do |validator|
      create_list :validator_block_history, 3,
                  validator: validator,
                  network: network,
                  batch_uuid: batch.uuid
    end.flatten

    {
      batch_uuid: batch.uuid,
      validators: validators,
      validator_histories: validator_histories,
      vote_account: vote_accounts,
      vote_account_histories: vote_account_histories,
      validator_block_histories: validator_block_histories
    }
  end
end
