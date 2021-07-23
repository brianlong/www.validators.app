# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV1Test < ActiveSupport::TestCase
  test 'relationship to validator' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1

    assert_not_nil score
    assert_equal validator.id, score.validator_id
  end

  test 'relationship has_one :ip' do
    address = '192.123.23.2'
    validator = create(:validator)
    validator_score_v1 = create(:validator_score_v1, validator: validator, ip_address: address)
    ip = create(:ip, address: address)
    
    assert_equal ip, validator_score_v1.ip
  end

  test 'calculate_total_score assigns a score of 0 if commission is 100' do
    validator_score_v1 = create(
      :validator_score_v1,
      validator: create(:validator, network: 'mainnet'),
      commission: 100,
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2
    )

    assert_equal 0, validator_score_v1.total_score
  end

  test 'assign_published_information_score' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1
    assert_equal 1, score.published_information_score
    validator.www_url = 'http://www.example.com'
    validator.details = 'Test details'
    validator.save
    score.save
    score.reload
    assert_equal 2, score.published_information_score
  end

  test 'assign_security_report_score' do
    score = FactoryBot.create(:validator_score_v1)
    assert_equal 1, score.security_report_score
  end

  test 'assign_software_version_score persists a software_version_score' do
    score = create(:validator_score_v1, software_version: '1.5.4')
    score.assign_software_version_score
    assert(score.software_version_score.present?)
  end

  test 'assign_software_version_score preserves the existing value if junk is passed' do
    score = create(:validator_score_v1, software_version: 'foo', software_version_score: 1)
    score.assign_software_version_score
    assert_equal 1, score.reload.software_version_score
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
    create(:validator_score_v1, data_center_key: 'datacenter1')
    create(:validator_score_v1, data_center_key: 'datacenter2')

    res = ValidatorScoreV1.by_data_centers('datacenter1')

    assert_equal 1, res.count
    assert_equal 'datacenter1', res.first.data_center_key
  end

  test 'should add new commission history when commission changed' do
    @batch = create(:batch, network: 'testnet')
    validator = create(:validator, network: 'testnet')
    score = create(
      :validator_score_v1,
      validator: validator,
      commission: 10,
      network: 'testnet'
    )
    create(:epoch_history, network: 'testnet', batch_uuid: @batch.uuid)

    assert_difference('CommissionHistory.count') do
      score.update(commission: 20)
    end
  end
end
