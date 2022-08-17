# frozen_string_literal: true

require "test_helper"

class GossipNodeLogicTest < ActiveSupport::TestCase
  include GossipNodeLogic

  setup do
    @mainnet_url = "https://api.mainnet-beta.solana.com"

    @payload = {
      network: "mainnet",
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
      assert_equal "mainnet", GossipNode.last.network
      refute GossipNode.where(identity: nil).exists?
      refute GossipNode.where(ip: nil).exists?
    end
  end
end
