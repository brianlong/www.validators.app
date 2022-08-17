# frozen_string_literal: true

require "test_helper"

class GossipNodeLogicTest < ActiveSupport::TestCase
  include GossipNodeLogic

  setup do
    @mainnet_url = "https://api.mainnet-beta.solana.com"
    @network = "mainnet"

    @payload = {
      network: @network,
      config_urls: [@mainnet_url]
    }

    @json_data = File.read("#{Rails.root}/test/json/gossip_nodes.json")
  end

  test "get_nodes adds gossip nodes to pipeline" do
    SolanaCliService.stub(:request, @json_data, ["gossip", @mainnet_url]) do
      p = Pipeline.new(200, @payload)
                  .then(&get_nodes)

      assert_equal 200, p.code
      refute p.payload[:current_nodes].blank?
    end
  end

  test "get_nodes returns error when solana returns no response" do
    SolanaCliService.stub(:request, {}.to_json, ["gossip", @mainnet_url]) do
      p = Pipeline.new(200, @payload)
                  .then(&get_nodes)

      assert_equal 500, p.code
      assert_equal "No nodes returned by cli", p.errors.message
    end
  end

  test "update_nodes creates new gossip nodes" do
    refute GossipNode.exists?

    SolanaCliService.stub(:request, @json_data, ["gossip", @mainnet_url]) do
      p = Pipeline.new(200, @payload)
                  .then(&get_nodes)
                  .then(&update_nodes)

      assert_equal 200, p.code
      refute p.payload[:current_nodes].blank?
      assert GossipNode.exists?
      assert_equal @network, GossipNode.last.network
      refute GossipNode.where(identity: nil).exists?
      refute GossipNode.where(ip: nil).exists?
    end
  end

  test "set_staked_flag correctly updates staked" do
    ip = "204.16.244.218"
    
    val = create(
      :validator,
      network: @network
    )
    create(
      :validator_score_v1,
      validator: val,
      active_stake: 123,
      network: @network
    )

    create(:validator_ip, validator: val, address: ip)

    SolanaCliService.stub(:request, @json_data, ["gossip", @mainnet_url]) do
      p = Pipeline.new(200, @payload)
                  .then(&get_nodes)
                  .then(&update_nodes)
                  .then(&set_staked_flag)

      staked_nodes = GossipNode.where(staked: true)

      assert_equal 200, p.code
      assert_equal 1, staked_nodes.count
      assert_equal ip, staked_nodes.last.ip
    end
  end
end
