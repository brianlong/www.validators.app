# frozen_string_literal: true

require 'test_helper'

class AsnLogicTest < ActiveSupport::TestCase
  include AsnLogic

  setup do
    ValidatorScoreV1.delete_all

    @ip = create(:ip, :ip_berlin) # asn: 54321
    val = create(:validator, network: 'testnet')

    @score = create(
      :validator_score_v1,
      validator: val,
      network: 'testnet',
      vote_distance_history: [1, 2, 3],
      ip_address: @ip.address,
      data_center_key: @ip.data_center_key
    )

    @payload = {
      network: 'testnet'
    }
  end

  teardown do
    if File.exist?("#{Rails.root}/log/test/asn_logic.log")
      File.delete("#{Rails.root}/log/test/asn_logic.log")
    end
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
    assert_equal 7, AsnStat.last.average_score
  end

  test "calculate_and_save_stats does not calc delinquent validator" do
    @score.update(delinquent: true)

    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)
                .then(&calculate_and_save_stats)

    assert_nil p.errors
    assert_equal 54_321, AsnStat.last.traits_autonomous_system_number
    assert AsnStat.last.data_centers.include?(@ip.data_center_key)
    assert_equal nil, AsnStat.last.average_score
  end

  test 'log_errors_to_file' do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)
                .then(&calculate_and_save_stats)
    begin
      throw 'test error'
    rescue => e
      p = Pipeline.new(500, p.payload, 'testing some error', e)
    end
    p.then(&log_errors_to_file)
    
    assert File.exist?("#{Rails.root}/log/test/asn_logic.log")
    error_lines = File.open("#{Rails.root}/log/test/asn_logic.log").map { |l| l }
    assert_equal true, error_lines[1].include?('test error')
  end
end
