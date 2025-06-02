# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV1Test < ActiveSupport::TestCase
  setup do
    @validator = create(:validator, network: 'mainnet')
    @validator_score_v1 = create(
      :validator_score_v1,
      validator: @validator
    )
  end

  test 'relationship to validator' do
    assert_not_nil @validator_score_v1
    assert_equal @validator.id, @validator_score_v1.validator_id
  end

  test 'relationship has_one data_center through validator' do
    data_center = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: data_center)
    validator_ip = create(:validator_ip, :active, validator: @validator, data_center_host: data_center_host)

    assert_equal @validator_score_v1.data_center, data_center
  end

  test "total_active_stake returns active stake for validators with data center assigned" do
    data_center = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: data_center)
    create(:validator_ip, :active, validator: @validator, data_center_host: data_center_host)

    validator2 = create(:validator, network: "mainnet")
    create(:validator_ip, :active, validator: validator2, data_center_host: data_center_host)
    create(:validator_score_v1, validator: validator2)

    validator_wo_data_center = create(:validator, network: "mainnet")
    create(
      :validator_score_v1,
      validator: validator_wo_data_center,
      active_stake: 200
    )

    expected_active_stake = @validator.score.active_stake + validator2.score.active_stake

    assert_equal ValidatorScoreV1.total_active_stake("mainnet"), expected_active_stake
  end

  test 'calculate_total_score assigns a score of 0 if commission is 100' do
    @validator_score_v1.update(
      commission: 100,
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2
    )

    assert_equal 0, @validator_score_v1.total_score
    assert_equal "N/A", @validator_score_v1.displayed_total_score
  end

  test 'calculate_total_score assigns a score of 0 if validator has admin_warning' do
    @validator.update(admin_warning: 'test warning')
    @validator_score_v1.calculate_total_score

    assert_equal 0, @validator_score_v1.total_score
    assert_equal "N/A", @validator_score_v1.displayed_total_score
  end

  test 'calculate_total_score assigns a score of -2 if validator has consensus_mods' do
    @validator.update(security_report_url: nil)
    @validator_score_v1.calculate_total_score
    total_score_before = @validator_score_v1.total_score
    @validator.update(consensus_mods: true)
    @validator_score_v1.calculate_total_score

    assert_equal (total_score_before - 2), @validator_score_v1.total_score
  end

  test 'calculate_total_score assigns a score of -2 and security score 0 if validator has consensus_mods' do
    total_score_before = @validator_score_v1.total_score
    @validator.update(consensus_mods: true)
    @validator_score_v1.calculate_total_score

    assert_equal (total_score_before - 3), @validator_score_v1.total_score
  end

  test 'calculate_total_score correctly calculate score' do
    @validator_score_v1.assign_attributes(
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2,
      published_information_score: 2,
      security_report_score: 1,
      software_version_score: 2,
      stake_concentration_score: 2,
      data_center_concentration_score: 2,
      authorized_withdrawer_score: 0,
      consensus_mods_score: 0
    )

    assert_equal 14, @validator_score_v1.calculate_total_score
  end

  test 'assign_published_information_score' do
    assert_equal 1, @validator_score_v1.published_information_score

    @validator.assign_attributes(
      www_url: 'http://www.example.com',
      details: 'Test details',
      keybase_id: nil
    )

    @validator.save
    @validator_score_v1.save
    @validator_score_v1.reload

    assert_equal 2, @validator_score_v1.published_information_score
  end

  test 'assign_security_report_score assigns 1 if validator has security report' do
    assert_equal 1, @validator_score_v1.security_report_score
  end

  test 'assign_security_report_score assigns 0 if validator has consensus_mods' do
    @validator.update(consensus_mods: true)
    @validator_score_v1.calculate_total_score

    assert_equal 0, @validator_score_v1.assign_security_report_score
    assert_equal 0, @validator_score_v1.security_report_score
  end

  test 'assign_consensus_mods_score assigns 0 by default' do
    assert_equal 0, @validator_score_v1.consensus_mods_score
  end

  test 'assign_consensus_mods_score assigns -2 if validator has consensus_mods' do
    @validator.update(consensus_mods: true)
    @validator_score_v1.calculate_total_score

    assert_equal -2, @validator_score_v1.consensus_mods_score
  end

  test 'assign_software_version_score persists a software_version_score' do
    @validator_score_v1.update_attribute(:software_version, '1.5.4')

    @validator_score_v1.assign_software_version_score('1.5.6')
    assert(@validator_score_v1.software_version_score.present?)
  end

  test 'assign_software_version_score preserves the existing value if junk is passed' do
    @validator_score_v1.update(
      software_version: 'foo',
      software_version_score: 1
    )

    @validator_score_v1.assign_software_version_score(nil)

    assert_equal 1, @validator_score_v1.reload.software_version_score
  end

  test 'assign_software_version_score scores 2 points for correct versions' do
    current_version = '1.5.4'
    create(:batch, software_version: '1.5.4')
    score1 = create(:validator_score_v1, network: 'testnet', software_version: '1.5.4')
    score2 = create(:validator_score_v1, network: 'testnet', software_version: '1.5.5')
    score3 = create(:validator_score_v1, network: 'testnet', software_version: '1.6.4')

    score1.assign_software_version_score(current_version)
    score2.assign_software_version_score(current_version)
    score3.assign_software_version_score(current_version)

    assert_equal 2, score1.reload.software_version_score
    assert_equal 2, score2.reload.software_version_score
    assert_equal 2, score3.reload.software_version_score
  end

  test 'assign_software_version_score scores 1 points for correct versions' do
    current_version = '1.5.4'
    other_software_versions = { "agave" => current_version }
    create(:batch, software_version: current_version, other_software_versions: other_software_versions)
    
    score1 = create(:validator_score_v1, network: 'testnet', software_version: '1.5.3')
    score2 = create(:validator_score_v1, network: 'testnet', software_version: '1.5.1')

    score1.assign_software_version_score(current_version)
    score2.assign_software_version_score(current_version)

    assert_equal 1, score1.reload.software_version_score
    assert_equal 1, score2.reload.software_version_score
  end

  test 'assign_software_version_score scores 0 points for correct versions' do
    current_version = '1.5.4'
    other_software_versions = { "agave" => current_version }
    create(:batch, software_version: current_version, other_software_versions: other_software_versions)

    @validator_score_v1.update(network: 'testnet', software_version: '1.4.4')
    @validator_score_v1.assign_software_version_score(current_version)

    assert_equal 0, @validator_score_v1.reload.software_version_score
  end

  test 'by_network_with_active_stake scope should return correct results' do
    create(:validator_score_v1, active_stake: 100, network: 'testnet')
    create(:validator_score_v1, active_stake: 0, network: 'testnet')
    create(:validator_score_v1, active_stake: 100, network: 'mainnet')

    res = ValidatorScoreV1.by_network_with_active_stake('testnet')

    assert_equal 1, res.count
    assert_equal 'testnet', res.first.network
    assert_equal 100, res.first.active_stake
  end

  test 'by_data_centers scope should return correct results' do
    data_center = create(:data_center, :china)
    data_center2 = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: data_center)
    data_center_host2 = create(:data_center_host, data_center: data_center2)
    validator = create(:validator)
    validator2 = create(:validator)

    validator_ip = create(:validator_ip, :active, validator: validator, data_center_host: data_center_host)
    validator_ip2 = create(:validator_ip, :active, validator: validator2, data_center_host: data_center_host2)


    validator_score = create(:validator_score_v1, validator: validator)
    validator_score2 = create(:validator_score_v1, validator: validator2)

    res = ValidatorScoreV1.by_data_centers(data_center.data_center_key)

    assert_equal 1, res.size
    assert_equal data_center.data_center_key, res.first.data_center_key
  end

  test 'should add new commission history when commission changed' do
    @batch = create(:batch, network: 'testnet')
    @validator_score_v1.update(
      commission: 10,
      network: 'testnet'
    )
    create(:epoch_history, network: 'testnet', batch_uuid: @batch.uuid)

    assert_difference('CommissionHistory.count') do
      @validator_score_v1.update(commission: 20)
    end
  end
end
