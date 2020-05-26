# frozen_string_literal: true

# This script will attempt to ping all of the other nodes shown in the gossip
# network and find the ping time from this node to the others.
#
# Prerequisites:
#   - Any recent version of Ruby. `sudo apt install ruby` should work.
#   - Local RPC running on your validator.
#
# Copy this fine in to your Solana home directory. Example to run:
#
#   `VALIDATORS_API_TOKEN=TOKEN_HERE ruby collect_ping_times.rb >> /home/brianlong/collect_ping_times.log &`
#
# Please note that we are sampling ping times on each node in the gossip
# network in a single thread, so this script will take a while to run. Be
# patient!
#
# CRON Example:
# */5 * * * * /bin/bash -l -c 'VALIDATORS_API_TOKEN=YOUR_TOKEN_HERE cd /home/SOLANA_USER/ && /usr/bin/ruby collect_ping_times.rb >> /home/SOLANA_USER/collect_ping_times.log 2>&1'
#
# NOTE: Your logs will be empty if there are no errors. All errors will be
# logged.
#
# Author: Brian Long

require 'uri'
require 'net/http'
require 'json'

# Script variables -- You generally won't need to change these
api_token = ENV['VALIDATORS_API_TOKEN']
# Adjust this if your local RPC is not on port 8899
rpc_url = 'http://127.0.0.1:8899' # 'https://testnet.solana.com:8899'
short_run = true # true for development, false for production

interrupted = false
trap('INT') { interrupted = true }

# CollectorLogic contains helper methods for the body of the script below.
module CollectorLogic
  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_url)
    # Parse the URL data into an URI object
    uri = URI.parse(rpc_url)

    # Create the HTTP session and send the request
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new(
        uri.request_uri,
        { 'Content-Type' => 'application/json' }
      )
      request.body = {
        'jsonrpc': '2.0', 'id': 1, 'method': rpc_method.to_s
      }.to_json
      http.request(request)
    end

    JSON.parse(response.body)
  end

  # Post the ping times to www.validators.app
  def post_ping_times(api_token, merged_results)
    # Parse the URL data into an URI object
    uri = URI.parse('https://www.validators.app/api/v1/collector')

    # Create the HTTP session and send the request
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new(
        uri.request_uri,
        {
          'Content-Type' => 'application/json',
          'Token' => api_token
        }
      )
      request.body = JSON.generate(
        {
          collector:
            {
              payload_type: 'ping_times',
              payload_version: 1,
              payload: JSON.generate(merged_results)
            }
        }
      )
      http.request(request)
    end
    # response.code
  end
end

# This is the start of the script
begin
  include CollectorLogic

  # Guards
  raise 'Please provide the VALIDATORS_API_TOKEN' if api_token.nil?

  # Capture my address & create a variable for my_ip
  my_address = `solana address`.strip
  my_ip = ''

  # Capture the current cluster_nodes from RPC
  cluster_nodes = rpc_request('getClusterNodes', rpc_url)
  # Example cluster_nodes:
  # {"jsonrpc"=>"2.0", "result"=>[{"gossip"=>"216.24.140.155:8001",
  # "pubkey"=>"5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
  # "rpc"=>"216.24.140.155:8899", "tpu"=>"216.24.140.155:8004",
  # "version"=>"1.1.14 c7d85758"}, {"gossip"=>"136.24.223.18:14501",
  # "pubkey"=>"aeypRbHck9k5zGuftrdSaUMfjJyTrjtaGJEtALt835y", "rpc"=>nil,
  # "tpu"=>"136.24.223.18:14504", "version"=>"1.1.12 devbuild"}, ...]}

  # Create an Array for the results
  i = 0
  sub_results = []
  # Loop through the cluster_nodes to gather ping data
  cluster_nodes['result'].each do |node|
    # Check for my address
    if my_address == node['pubkey']
      my_ip = node['gossip'].to_s.split(':')[0] if my_ip.empty?
      next
    end

    # Skip out early for development
    if short_run
      i += 1
      next if i > 5
    end

    node_ip = node['gossip'].to_s.split(':')[0]

    # Ping and collect the average time over 4 attempts. Gather the results into
    # an Array.
    ping_results = `ping -c 4 #{node_ip}`.split("\n")

    # Pull the good stuff out of the Array.
    # Example output:
    # --- ping.proxyrain.net ping statistics ---
    # 5 packets transmitted, 5 received, 0% packet loss, time 4001ms
    # rtt min/avg/max/mdev = 0.881/1.238/2.428/0.597 ms
    ping_results.each do |ping|
      next unless ping.include?('rtt') || ping.include?('round-trip')

      ping_stats = ping.split('=')[1].split('/')
      sub_results << {
        'to_account' => node['pubkey'],
        'to_ip' => node_ip,
        'min_ms' => ping_stats[0].to_f,
        'avg_ms' => ping_stats[1].to_f,
        'max_ms' => ping_stats[2].to_f,
        'mdev_ms' => ping_stats[3].gsub('ms', '').strip.to_f
      }
    end
    raise 'Interrupted' if interrupted
  end

  # merged_results holds the final result set to post to the API
  merged_results = sub_results.map do |pt|
    pt.merge(
      'network' => 'testnet',
      'from_account' => my_address,
      'from_ip' => my_ip,
      'observed_at' => Time.now
    )
  end

  # Post the merged results and leave the script
  post_ping_times(api_token, merged_results)
rescue StandardError => e
  puts ''
  puts e.class
  puts e.message
  puts e.backtrace
  puts ''
end
