# frozen_string_literal: true

require 'test_helper'

class IpableTest < ActiveSupport::TestCase
  setup do
    @validator = create(:validator)
    @gossip_node = create(:gossip_node)
    @validator_ip = create(:validator_ip)
  end

  test "belongs_to correctly displays validator when type is validator" do
    ipable = Ipable.create(ip_id: @validator_ip.id, ipable_id: @validator.id, ipable_type: "Validator")    
    assert_equal @validator, ipable.validator
  end

  test "belongs_to correctly displays gossip_node when type is gossip_node" do
    ipable = Ipable.create(ip_id: @validator_ip.id, ipable_id: @gossip_node.id, ipable_type: "GossipNode")    
    assert_equal @gossip_node, ipable.gossip_node
  end

  test "has_one ip correctly displays validator_ip" do
    ipable = Ipable.create(ip_id: @validator_ip.id, ipable_id: @gossip_node.id, ipable_type: "GossipNode")    
    assert_equal @validator_ip, ipable.validator_ip
  end
end
