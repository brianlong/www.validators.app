# frozen_string_literal: true

require "test_helper"

class DataCenterTest < ActiveSupport::TestCase
  def setup
    @data_center = create(:data_center, :berlin)
  end

  test "relationship data_center_hosts returns assigned data_center_hosts" do
    dch = create(:data_center_host, data_center: @data_center)
    dch2 = create(:data_center_host, data_center: @data_center)

    assert_equal 2, @data_center.data_center_hosts.size
    assert_includes @data_center.data_center_hosts, dch
    assert_includes @data_center.data_center_hosts, dch2
  end

  test "relationship validator_ips returns validator_ips through data_center_hosts" do
    validator = create(:validator)
    dch = create(:data_center_host, data_center: @data_center)
    vip = create(:validator_ip, data_center_host: dch, validator: validator)
    vip2 = create(:validator_ip, data_center_host: dch, validator: validator, address: "0.0.0.0")

    assert_equal 2, @data_center.validator_ips.size
    assert_includes @data_center.validator_ips, vip
    assert_includes @data_center.validator_ips, vip2
  end

  test "relationship validator_ips_active" \
       "returns only active validator_ips through data_center_hosts" do
    validator = create(:validator)
    dch = create(:data_center_host, data_center: @data_center)
    vip = create(:validator_ip, data_center_host: dch, validator: validator)
    vip2 = create(:validator_ip, :active, data_center_host: dch, validator: validator, address: "0.0.0.0")

    assert_equal 1, @data_center.validator_ips_active.size
    assert_includes @data_center.validator_ips_active, vip2
  end

  test "relationship validators returns validators with active validator_ips" \
       "through data_center_hosts" do
    validator = create(:validator)
    dch = create(:data_center_host, data_center: @data_center)
    vip = create(:validator_ip, data_center_host: dch, validator: validator)
    vip2 = create(:validator_ip, :active, data_center_host: dch, validator: validator, address: "0.0.0.0")

    assert_equal 1, @data_center.validators.size
    assert_includes @data_center.validators, validator
  end

  test "relationship validator_score_v1s returns validator_score_v1s" \
       "with active validator_ips through data_center_hosts" do
    validator = create(:validator, :with_score)
    validator2 = create(:validator, :with_score)
    validator3 = create(:validator, :with_score)
    validator4_inactive_ip = create(:validator, :with_score) # this score shouldn/t be included

    dch = create(:data_center_host, data_center: @data_center)
    dch2 = create(:data_center_host, data_center: @data_center)

    vip = create(:validator_ip, :active, data_center_host: dch, validator: validator, address: "0.0.0.1")
    vip2 = create(:validator_ip, :active, data_center_host: dch2, validator: validator2, address: "0.0.0.2")
    vip3 = create(:validator_ip, :active, data_center_host: dch2, validator: validator3, address: "0.0.0.3")
    vip4 = create(:validator_ip, data_center_host: dch, validator: validator4_inactive_ip, address: "0.0.0.4")

    assert_equal 3, @data_center.validator_score_v1s.size
    assert_includes @data_center.validator_score_v1s, validator.validator_score_v1
    assert_includes @data_center.validator_score_v1s, validator2.validator_score_v1
    assert_includes @data_center.validator_score_v1s, validator3.validator_score_v1
  end

  test "relationship has_many gossip_nodes returns gossip_nodes through data_center_hosts" do
    node = create(:gossip_node)
    dch = create(:data_center_host, data_center: @data_center)
    vip = create(:validator_ip, data_center_host: dch, address: node.ip)

    assert_equal 1, @data_center.gossip_nodes.count
    assert_equal node, @data_center.gossip_nodes.first
  end

  test "scope by_data_center_key returns data_centers by given data_center_key" do
    create(:data_center, :china)

    data_centers = DataCenter.by_data_center_key(@data_center.data_center_key)

    assert_equal 1, data_centers.size
    assert_equal @data_center, data_centers.first
  end

  test "scope for_api returns data_centers with specified fields" do
    assert_equal DataCenter::FIELDS_FOR_API.map(&:to_s), DataCenter.for_api.first.attributes.keys.sort
  end

  test "#to_builder returns correct data" do
    expected_result = { 
      data_center_key: "12345-DE-Berlin",
      autonomous_system_number: 12345, 
      latitude: "51.2993", 
      longitude: "9.491" 
    }.to_json

    assert_equal expected_result, @data_center.to_builder.target!
  end

  test "before_save #assign_data_center_key assigns key correctly" do
    assert_equal "12345-DE-Berlin", @data_center.data_center_key
  end
end
