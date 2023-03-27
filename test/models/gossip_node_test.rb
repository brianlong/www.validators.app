# frozen_string_literal: true

require "test_helper"

class GossipNodeTest < ActiveSupport::TestCase
  setup do
    @ip = "10.20.30.40"
    @node = create(:gossip_node, ip: @ip, account: "test_account")
  end

  test "add_validator_ip creates validator_ip with correct ip" do
    refute ValidatorIp.where(address: @ip, is_active: true).exists?
    @node.add_validator_ip

    assert ValidatorIp.where(address: @ip, is_active: true).exists?
  end

  test "add_validator_ip creates validator_ip only if necessery" do
    create(:validator_ip, address: @ip, is_active: true)

    5.times do
      @node.add_validator_ip
    end

    assert_equal 1, ValidatorIp.where(address: @ip).count
  end

  test "has_one validator_ip should return correct validator_ip" do
    val_ip = create(:validator_ip, address: @ip)

    assert_equal @node.validator_ip, val_ip
  end

  test "has_one validator should return correct validator" do
    val = create(:validator, account: @node.account)

    assert_equal val, @node.validator
  end

  test "has_one data_center should return correct data_center" do
    data_center = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: data_center)
    val_ip = create(:validator_ip, address: @ip, data_center_host: data_center_host, is_active: true)

    assert_equal data_center, @node.data_center
  end

  test "relationship has_one validator_ip_active returns correct validator_ip" do
    validator_ip = create(:validator_ip, validator: @validator, address: @ip)
    validator_ip2 = create(:validator_ip, :active, validator: @validator, address: @ip)

    assert_equal validator_ip2, @node.validator_ip_active
  end

  test "active scope returns only active nodes" do
    inactive_node = create(:gossip_node, :inactive)

    assert_equal 1, GossipNode.active.count
    refute GossipNode.active.include? inactive_node
  end
end
