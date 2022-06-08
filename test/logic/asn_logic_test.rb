# frozen_string_literal: true

require 'test_helper'

class AsnLogicTest < ActiveSupport::TestCase
  include AsnLogic

  setup do
    @data_center = create(:data_center, :berlin)
    @data_center_host = create(:data_center_host, data_center: @data_center)
    @validator = create(:validator, network: 'testnet')
    @validator_ip = create(:validator_ip, :active, validator: @validator, data_center_host: @data_center_host)

    create(
      :validator_score_v1,
      validator: @validator,
      network: 'testnet',
      vote_distance_history: [1, 2, 3],
      ip_address: @validator_ip.address
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
    assert_equal [12_345], p.payload[:asns].keys
  end

  test "gather_scores" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)

    assert_nil p.errors
    assert_equal 1, p.payload[:scores].size
    assert_equal @validator_ip.address, p.payload[:scores].last.ip_address
  end

  test "prepare_asn_stats" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)

    assert_nil p.errors
    assert_equal 1, p.payload[:asn_stats].count
    assert_equal 12_345, p.payload[:asn_stats].last.traits_autonomous_system_number
  end

  test "calculate_and_save_stats" do
    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)
                .then(&calculate_and_save_stats)

    assert_nil p.errors
    assert_equal 12_345, AsnStat.last.traits_autonomous_system_number
    assert AsnStat.last.data_centers.include?(@data_center.data_center_key)
    assert_equal 7, AsnStat.last.average_score
  end

  test "calculate_and_save_stats does not calc delinquent validator" do
    @validator.update(is_active: false)

    p = Pipeline.new(200, @payload)
                .then(&gather_asns)
                .then(&gather_scores)
                .then(&prepare_asn_stats)
                .then(&calculate_and_save_stats)

    assert_nil p.errors
    assert_equal 12_345, AsnStat.last.traits_autonomous_system_number
    assert AsnStat.last.data_centers.include?(@data_center.data_center_key)
    assert_equal 0, AsnStat.last.average_score
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
