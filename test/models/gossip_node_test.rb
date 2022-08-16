require "test_helper"

class GossipNodeTest < ActiveSupport::TestCase
  setup do
    @ip = "10.20.30.40"
  end

  test "add_validator_ip creates validator_ip with correct ip" do
    refute ValidatorIp.where(address: @ip).exists?

    node = create(:gossip_node, ip: @ip)
    node.add_validator_ip

    assert ValidatorIp.where(address: @ip).exists?
  end

  test "add_validator_ip creates validator_ip only if necessery" do
    create(:validator_ip, address: @ip)
    node = create(:gossip_node, ip: @ip)

    5.times do
      node.add_validator_ip
    end

    assert_equal 1, ValidatorIp.where(address: @ip).count
  end

  test "has_one validator_ip should return correct validator_ip" do
    val_ip = create(:validator_ip, address: @ip)
    node = create(:gossip_node, ip: @ip)

    assert_equal node.validator_ip, val_ip
  end
end
