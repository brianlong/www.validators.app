# frozen_string_literal: true

# This script will attempt to ping all of the other nodes shown in the cluster
# and find the ping time from this node to the others. It will then post the
# results to www.validators.app
#
# Prerequisites:
#   - Create a user account on https://www.validators.app
#   - Verify your account through email
#   - Get your VALIDATORS_API_TOKEN from the app
#
# Software Requirements:
#   - Any recent version of Ruby. `sudo apt install ruby` should do it.
#   - Local RPC running on your *staked* validator (I haven't tested this from
#     a spy node or an un-staked validator).
#   - Copy this file in to your validator home directory:
#
#  `curl https://raw.githubusercontent.com/brianlong/www.validators.app/master/client_scripts/collect_ping_times_loop.rb > collect_ping_times_loop.rb`
#
# You will pass in your VALIDATORS_API_TOKEN from an environment variable or
# an option on the command line. Example to run using an environment variable:
#
#   `VALIDATORS_API_TOKEN=TOKEN_HERE ruby collect_ping_times_loop.rb >>  collect_ping_times_loop.log &`
#
# Example to run using a command line option for the API token:
#
#   `ruby collect_ping_times_loop.rb --token TOKEN_HERE >> collect_ping_times_loop.log &`
#
# This script will run in a loop until it receives an interrupt. You can use
# systemd to monitor the process and restart if it crashes.
#
# Coming Soon: Sample service file.
#
# Command line options (None of these are required).
#
#  --local-app or -l if you are me doing development on my local workstation.
#  --short-run or -s can be used for development. This option will stop the
#    script after 5 nodes.
#  --token or -t followed by your API token. Required if you are not using an
#    environment variable for the token.
#  --url or -u if you need to use a different RPC URL or port. Pass the full
#    url & port like --url 'http://127.0.0.1:8899'
#
# Please note that we are sampling ping times on each node in the cluster
# in a single thread, so this script will take a while to run. Be patient!
# I do not want to disturb your running validator with bursts of traffic.
#
# NOTE: Your logs will be empty if there are no errors. All errors will be
# seen in your designated log file.
#
# Author: Brian Long
# Script Version: 1.0.2 -- Sanitize IP address

require 'uri'
require 'net/http'
require 'json'
require 'getoptlong'
require 'timeout'
require 'shellwords'
require 'ipaddr'

# Capture options from the command line
options = GetoptLong.new(
  ['--local-app', '-l', GetoptLong::OPTIONAL_ARGUMENT],
  ['--short-run', '-s', GetoptLong::OPTIONAL_ARGUMENT],
  ['--token', '-t', GetoptLong::OPTIONAL_ARGUMENT],
  ['--url', '-u', GetoptLong::OPTIONAL_ARGUMENT]
)

# Default script variables -- You generally won't need to change these, but you
# can pass in optional command line options for each as described above.
api_token = ENV['VALIDATORS_API_TOKEN']
rpc_url = 'http://127.0.0.1:8899' # Not 'https://testnet.solana.com:8899'!
short_run = false # true for development, false for production
app_host = 'https://www.validators.app'

options.each do |option, argument|
  case option
  when '--local-app'
    app_host = 'http://localhost:3000'
  when '--short-run'
    short_run = true
  when '--token'
    api_token = argument
  when '--url'
    rpc_url = argument
  end
end

# Send an interrupt with `ctrl-c` or `kill` to stop the script. Results will
# not be posted to the validators.app server.
interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

# CollectorLogic contains helper methods for the body of the script seen below.
module CollectorLogic
  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_url)
    # Parse the URL data into an URI object
    uri = URI.parse(rpc_url)

    # Create the HTTP session and send the request
    Timeout.timeout(10) do
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
  end

  # Post the ping times to www.validators.app
  def post_ping_times(api_token, merged_results, app_host)
    # Parse the URL data into an URI object
    uri = URI.parse("#{app_host}/api/v1/collector")

    use_ssl = app_host.include?('https') ? true : false

    # Create the HTTP session and send the request
    Timeout.timeout(10) do
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
        request = Net::HTTP::Post.new(
          uri.request_uri,
          {
            'Content-Type' => 'application/json',
            'Token' => api_token
          }
        )
        request.body = JSON.generate(
          {
            payload_type: 'ping_times',
            payload_version: 1,
            payload: JSON.generate(merged_results)
          }
        )
        http.request(request)
      end
      response.code
    end
  end
end

# This is the start of the script
begin
  loop do
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

      # Grab the IP address for this node from gossip data
      node_ip = node['gossip'].to_s.split(':')[0]

      # Skip this record if the node_ip is not a valid IP address
      # ipaddr = IPAddr.new(node_ip)
      next unless IPAddr.new(node_ip).ipv4?

      # Ping and collect the average time over 4 attempts. Gather the results
      # into an Array.
      ping_results = `ping -c 4 #{Shellwords.escape(node_ip)}`.split("\n")

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
          'mdev' => ping_stats[3].gsub('ms', '').strip.to_f
        }
      end
      # If interrupted, we will leave without posting results.
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

    # Post the merged results and repeat the loop unless interrupted first.
    raise 'Interrupted' if interrupted

    _code = post_ping_times(api_token, merged_results, app_host)
  end
rescue StandardError => e
  # Write errors to I/O so it can be seen on the console or in the log file.
  puts ''
  puts Time.now.to_s
  puts e.class
  puts e.message
  puts e.backtrace
  puts ''
end
