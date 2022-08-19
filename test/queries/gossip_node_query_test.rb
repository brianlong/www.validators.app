require 'test_helper'

class GossipNodeQueryTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"

    @node = create(:gossip_node, network: @network)
    create(:gossip_node, network: "testnet")
  end

  test "GossipNodeQuery returns results by network" do
    results = GossipNodeQuery.new("mainnet").call

    assert_equal 1, results.count
    assert_equal @network, results.first.network
  end
end
