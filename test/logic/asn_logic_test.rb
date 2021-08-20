# frozen_string_literal: true

require 'test_helper'

class AsnLogicTest < ActiveSupport::TestCase
  include AsnLogic

  setup do
    ValidatorScoreV1.delete_all

    @ip = create(:ip, :ip_berlin) # asn: 54321
    val = create(:validator, network: 'testnet')

    create(
      :validator_score_v1,
      validator: val,
      data_center_key: @ip.data_center_key,
      network: 'testnet',
      vote_distance_history: [1, 2, 3],
      ip_address: @ip.address,
      data_center_key: @ip.data_center_key
    )

    @payload = {
      network: 'testnet'
    }
  end

  test "gather_asns" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)

    assert_nil p.errors
    assert_equal [54_321], p.payload[:asns].keys
  end

  test "gather_scores" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)

    assert_nil p.errors
    assert_equal 1, p.payload[:scores].count
    assert_equal @ip.address, p.payload[:scores].last.ip_address
  end

  test "prepare_asn_stats" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)

    assert_nil p.errors
    assert_equal 1, p.payload[:asn_stats].count
    assert_equal 54_321, p.payload[:asn_stats].last.traits_autonomous_system_number
  end

  test "calculate_and_save_stats" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)
                .then(&calculate_and_save_stats)

    assert_nil p.errors
    assert_equal 54_321, AsnStat.last.traits_autonomous_system_number
    assert AsnStat.last.data_centers.include?(@ip.data_center_key)
    assert_equal 2, AsnStat.last.vote_distance_moving_average
  end
end
