# frozen_string_literal: true

require "test_helper"

class SortedDataCenterTest < ActiveSupport::TestCase

  setup do
    scores_china = []
    scores_berlin = []

    data_center_china = create(:data_center, :china)
    data_center_berlin = create(:data_center, :berlin)
    data_center_frankfurt = create(:data_center, :frankfurt)

    3.times do
      ip_address = Faker::Internet.ip_v4_address
      validator = create(:validator)
      data_center_host = create(:data_center_host, data_center: data_center_china)
      validator_ip = create(
        :validator_ip,
        :active,
        address: ip_address,
        validator: validator,
        data_center_host: data_center_host
      )

      score = create(
        :validator_score_v1,
        ip_address: ip_address,
        active_stake: 100,
        network: "testnet",
        validator: validator
      )
      scores_china << score
    end

    2.times do
      ip_address = Faker::Internet.ip_v4_address
      validator = create(:validator)
      data_center_host = create(:data_center_host, data_center: data_center_berlin)

      validator_ip = create(
        :validator_ip,
        :active,
        address: ip_address,
        validator: validator,
        data_center_host: data_center_host
      )

      score = create(
        :validator_score_v1,
        ip_address: ip_address,
        active_stake: 100,
        network: "testnet",
        validator: validator
      )

      scores_berlin << score
    end

    3.times do
      ip_address = Faker::Internet.ip_v4_address
      validator = create(:validator)
      data_center_host = create(:data_center_host, data_center: data_center_frankfurt)

      validator_ip = create(
        :validator_ip,
        :active,
        address: ip_address,
        validator: validator,
        data_center_host: data_center_host
      )

      score = create(
        :validator_score_v1,
        ip_address: ip_address,
        active_stake: 100,
        network: "testnet",
        validator: validator
      )

      scores_berlin << score
    end

    2.times do
      ip_address = Faker::Internet.ip_v4_address
      validator = create(:validator, is_active: false)
      data_center_host = create(:data_center_host, data_center: data_center_berlin)

      validator_ip = create(
        :validator_ip,
        :active,
        address: ip_address,
        validator: validator,
        data_center_host: data_center_host
      )

      score = create(
        :validator_score_v1,
        ip_address: ip_address,
        active_stake: 100,
        network: "testnet",
        validator: validator
      )

      scores_berlin << score
    end

    scores_china.first.update(delinquent: true)
    scores_china.last.update(delinquent: true)
    scores_berlin.first.update(delinquent: true)
  end

  test "when sort_by_asn and count returns correct result" do
    result = SortedDataCenters.new(
      sort_by: "asn",
      network: "testnet",
      secondary_sort: "count"
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 2, result[:results][0][1][:data_centers].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 1, result[:results][0][1][:delinquent_validators] # for traits_autonomous_system_number: 12345
    assert_equal 2, result[:results][1][1][:delinquent_validators] # for traits_autonomous_system_number: 54321
    assert_equal result[:results][0][1][:count], 5
  end

  test "when sort_by_data_centers and count returns correct result" do
    result = SortedDataCenters.new(
      sort_by: "data_center",
      network: "testnet",
      secondary_sort: "count"
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 3, result[:results].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 2, result[:results][0][1][:delinquent_validators] # 12345-CN-Asia/Shanghai
    assert_equal 1, result[:results][2][1][:delinquent_validators] # 12345-DE-Europe/CET
    assert_equal result[:results][0][1][:count], 3
  end

  test "when sort_by_asn and stake returns correct result" do
    result = SortedDataCenters.new(
      sort_by: "asn",
      network: "testnet",
      secondary_sort: "stake"
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 2, result[:results][0][1][:data_centers].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 1, result[:results][0][1][:delinquent_validators] # for traits_autonomous_system_number: 12345
    assert_equal 2, result[:results][1][1][:delinquent_validators] # for traits_autonomous_system_number: 54321
    assert_equal result[:results][0][1][:active_stake_from_active_validators], 500
  end

  test "when sort_by_data_centers and stake returns correct result" do
    result = SortedDataCenters.new(
      sort_by: "data_center",
      network: "testnet",
      secondary_sort: "stake"
    ).call

    assert_equal 8, result[:total_population]
    assert_equal 800, result[:total_stake]
    assert_equal 3, result[:results].count
    assert_equal 3, result[:total_delinquent]
    assert_equal 2, result[:results][0][1][:delinquent_validators] # 12345-CN-Asia/Shanghai
    assert_equal 1, result[:results][2][1][:delinquent_validators] # 12345-DE-Europe/CET
    assert_equal result[:results][0][1][:active_stake_from_active_validators], 300
  end
end
