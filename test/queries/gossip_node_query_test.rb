# frozen_string_literal: true

require "test_helper"

class GossipNodeQueryTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"

    @node = create(
      :gossip_node,
      network: @network,
      staked: true,
      identity: "exampleIdentity"
    )
    create(:gossip_node, network: "testnet")
    create(:gossip_node, network: "mainnet", staked: false)
  end

  test "GossipNodeQuery returns results by network" do
    results = GossipNodeQuery.new(network: @network).call

    assert_equal 2, results.size
    assert_equal @network, results.first["network"]
  end

  test "GossipNodeQuery returns only staked nodes with staked set to true" do
    results = GossipNodeQuery.new(network: @network).call(staked: true)

    assert_equal 1, results.size
    assert results.first["staked"]
  end

  test "GossipNodeQuery returns nodes within a given limit" do
    results = GossipNodeQuery.new(network: @network).call(per: 1)
    assert_equal 1, results.size

    results = GossipNodeQuery.new(network: @network).call(per: 2)
    assert_equal 2, results.size
  end

  test "GossipNodeQuery returns correct fields" do
    results = GossipNodeQuery.new(network: @network).call

    assert_equal GossipNodeQuery.query_fields_compact, results.first.attributes.keys
  end
end
