# frozen_string_literal: true

require "test_helper"

class GossipNodeQueryTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"

    @node = create(
      :gossip_node,
      network: @network,
      staked: true,
      account: "exampleAccount"
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

  test "GossipNodeQuery returns only non-staked nodes with staked set to false" do
    results = GossipNodeQuery.new(network: @network).call(staked: false)

    assert_equal 1, results.size
    refute results.first["staked"]
  end

  test "GossipNodeQuery returns nodes within a given limit" do
    results = GossipNodeQuery.new(network: @network).call(per: 1)
    assert_equal 1, results.size

    results = GossipNodeQuery.new(network: @network).call(per: 2)
    assert_equal 2, results.size
  end

  test "GossipNodeQuery returns correct fields" do
    query = GossipNodeQuery.new(network: @network)
    results = query.call

    expected_fields = query.query_fields.split(", ").map{ |q| q.split(".")[1]}.uniq
    expected_fields.map{|f| f.gsub!(/.*\sas\s/, "")}
    assert_equal expected_fields, results.first.attributes.keys
  end
end
