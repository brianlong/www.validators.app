require 'test_helper'

class SortedDataCenterTest < ActiveSupport::TestCase

  setup do
    3.times do
      ip = create(:ip_china)
      create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )
    end
    2.times do
      ip = create(
        :ip_berlin, 
        traits_autonomous_system_number: 12345
      )
      create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )
    end
    3.times do
      ip = create(:ip_berlin)
      create(
        :validator_score_v1,
        ip_address: ip.address,
        active_stake: 100,
        network: 'testnet',
        data_center_key: ip.data_center_key
      )
    end
  end

  test 'SortedDataCenters when sort_by_asn returns correct result' do
    result = SortedDataCenters.new(
      sort_by: 'asn',
      network: 'testnet'
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 2, result[:results][0][1][:data_centers].count
  end

  test 'SortedDataCenters when sort_by_data_centers returns correct result' do
    result = SortedDataCenters.new(
      sort_by: 'data_center',
      network: 'testnet'
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 3, result[:results].count
  end
end