# frozen_string_literal: true

# bundle exec ruby script/get_cluster_nodes_gossip.rb
require File.expand_path('../config/environment', __dir__)


config_urls = ["https://nyc4.rpcpool.com", "https://nyc1.rpcpool.com", "https://api.rpcpool.com", "https://api.mainnet-beta.solana.com"]
# config_urls = ["https://api.testnet.solana.com"]

class SolanaWrapper; include SolanaLogic; end


validators_json = SolanaWrapper.new.rpc_request('getClusterNodes', config_urls)

validators_json['result'].each do |hsh|
  gossip = hsh['gossip']
  pub_key = hsh['pubkey']

  if gossip.split(':')[0].blank?
    p pub_key
    p gossip
  end
end