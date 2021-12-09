require 'test_helper'

class SortedDataCenterTest < ActiveSupport::TestCase

  setup do
    scores_china = []
    scores_berlin = []

    3.times do
      ip = create(:ip, :ip_china)
      score = create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )
      scores_china << score
    end
    2.times do
      ip = create(
        :ip,
        :ip_berlin,
        traits_autonomous_system_number: 12345
      )
      score = create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )

      scores_berlin << score
    end
    3.times do
      ip = create(:ip, :ip_berlin)
      score = create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )

      scores_berlin << score
    end

    scores_china.first.update(delinquent: true)
    scores_berlin.first.update(delinquent: true)
    scores_berlin.last.update(delinquent: true)
  end

  test 'SortedDataCenters when sort_by_asn returns correct result' do
    result = SortedDataCenters.new(
      sort_by: 'asn',
      network: 'testnet'
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 2, result[:results][0][1][:data_centers].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 2, result[:results][0][1][:delinquent_validators] # for traits_autonomous_system_number: 12345
    assert_equal 1, result[:results][1][1][:delinquent_validators] # for traits_autonomous_system_number: 54321

  end

  test 'SortedDataCenters when sort_by_data_centers returns correct result' do
    result = SortedDataCenters.new(
      sort_by: 'data_center',
      network: 'testnet'
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 3, result[:results].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 1, result[:results][0][1][:delinquent_validators] # 12345-CN-Asia/Shanghai
    assert_equal 1, result[:results][1][1][:delinquent_validators] # 54321-DE-Europe/CET
    assert_equal 1, result[:results][2][1][:delinquent_validators] # 12345-DE-Europe/CET
  end
end
