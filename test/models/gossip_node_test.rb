# frozen_string_literal: true

require "test_helper"

class GossipNodeTest < ActiveSupport::TestCase
  setup do
    @ip = "10.20.30.40"
    @node = create(:gossip_node, ip: @ip, identity: "test_identity")
  end

  test "add_validator_ip creates validator_ip with correct ip" do
    refute ValidatorIp.where(address: @ip).exists?
    @node.add_validator_ip

    assert ValidatorIp.where(address: @ip).exists?
  end

  test "add_validator_ip creates validator_ip only if necessery" do
    create(:validator_ip, address: @ip)

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
    val = create(:validator, account: @node.identity)

    assert_equal val, @node.validator
  end

  test "has_one data_center should return correct data_center" do
    data_center = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: data_center)
    val_ip = create(:validator_ip, address: @ip, data_center_host: data_center_host)

    assert_equal data_center, @node.data_center
  end
end
