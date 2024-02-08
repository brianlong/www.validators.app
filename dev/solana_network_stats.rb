# frozen_string_literal: true

# This script will attempt to ping all of the other nodes shown in the gossip
# network and find the ping time from this node to the others. Example to run:
#
#   `ruby solana_network_stats.rb >> /home/brianlong/solana_network_stats.log &`
#
# Please note that we are sampling ping times on each node in the gossip
# network in a single thread, so this script will take a while to run. Be
# patient!
#
# CRON Example:
# 1,11,21,31,41,51 * * * * /bin/bash -l -c 'cd /home/brianlong/ && /usr/bin/ruby solana_network_stats.rb >> /home/brianlong/solana_network_stats.log 2>&1'
#
# Author: Brian Long

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

require 'csv'

interrupted = false
trap('INT') { interrupted = true }  unless Rails.env.test?

begin
  # Set short_run = true for short runs in development mode. false for
  # production
  short_run = true

  start_time = Time.now

  # Save my address so I can skip it later
  my_address = `solana address`.strip
  # Prepare a variable to hold my IP address if it is available on gossip
  my_ip = ''

  # Load the gossip nodes into an Array
  gossip_lines = `solana gossip`.split("\n")

  # Prepare a Hash for the final results
  nodes = {}

  puts ''
  puts "My ID is #{my_address[0..3]}...#{my_address[-4..-1]}"
  puts 'Network stats are calculated from me to you.'
  puts ''

  i = 0
  gossip_lines.each do |line|
    # guards
    next if line.include?('IP Address')
    next if line.include?('Nodes')
    next if line.include?('-+-')

    # Skip out early for development
    if short_run
      i += 1
      next if i > 5
    end

    # split the node data from the line
    node = line.split('|')
    node_ip = node[0].strip
    node_id = node[1].strip

    # Capture my IP address and skip to the next node.
    if line.include?(my_address)
      my_ip = node_ip
      next
    end

    # Add a new record to the nodes Hash
    nodes[node_id] = {ip: node_ip}
    nodes[node_id][:timestamp] = Time.now

    # Ping and collect the average time over 5 attempts. Gather the results into
    # an Array.
    ping_results = `ping -c 5 #{node_ip}`.split("\n")

    # Pull the good stuff out of the Array.
    # Example output:
    # --- ping.proxyrain.net ping statistics ---
    # 5 packets transmitted, 5 received, 0% packet loss, time 4001ms
    # rtt min/avg/max/mdev = 0.881/1.238/2.428/0.597 ms
    ping_results.each do |ping|
      next unless ping.include?('rtt') || ping.include?('round-trip')
      ping_stats = ping.split('=')[1].split('/')
      nodes[node_id][:min_ms]    = ping_stats[0].to_f
      nodes[node_id][:avg_ms]    = ping_stats[1].to_f
      nodes[node_id][:max_ms]    = ping_stats[2].to_f
      nodes[node_id][:mdev_ms]   = ping_stats[3].gsub('ms', '').strip.to_f
    end
    raise 'Interrupted' if interrupted
  end

  # Calculate Average Ping Times
  average_times = nodes.map{ |k,v| v[:avg_ms] unless v[:avg_ms].nil? }
  average_times = average_times.reject { |a| a.to_s.empty? }
  overall_average_time = \
    average_times.inject{ |sum, el| sum + el }.to_f / average_times.size

  min_times = nodes.map{ |k,v| v[:min_ms] unless v[:min_ms].nil? }
  min_times = min_times.reject { |a| a.to_s.empty? }
  overall_min_time = min_times.min

  max_times = nodes.map{ |k,v| v[:max_ms] unless v[:max_ms].nil? }
  max_times = max_times.reject { |a| a.to_s.empty? }
  overall_max_time = max_times.max

  # Calculate bandwidth currently used
  # ifstat -T 5 1
  #       eth0               Total
  # KB/s in  KB/s out   KB/s in  KB/s out
  # 2388.48   6944.72   2388.48   6944.72
  bandwidth_results = `ifstat -T 5 1`.split("\n")
  bandwidth_array = bandwidth_results.last.gsub('  ', ' ').split(' ')
  bandwidth_in  = bandwidth_array[-2].to_f
  bandwidth_out = bandwidth_array[-1].to_f

  overall_timestamp = Time.now

  # Put some data to the console for logging
  puts [
    'Public ID'.ljust(11),
    'Min'.ljust(9),
    'Avg'.ljust(9),
    'Max'.ljust(9),
    'Std. Dev.'.ljust(9),
  ].join(' | ')
  puts ['-'*11,'-'*9,'-'*9,'-'*9,'-'*9].join('-|-')

  nodes.each do |k,v|
    puts [
           "#{k[0..3]}...#{k[-4..-1]}".ljust(11),
           (v[:min_ms].nil? ? '' : sprintf('%.2f', v[:min_ms])).rjust(9),
           (v[:avg_ms].nil? ? '' : sprintf('%.2f', v[:avg_ms])).rjust(9),
           (v[:max_ms].nil? ? '' : sprintf('%.2f', v[:max_ms])).rjust(9),
           (v[:mdev_ms].nil? ? '' : sprintf('%.2f', v[:mdev_ms])).rjust(9)
          ].join(' | ')
  end

  # Append Individual Validator Ping Times to a CSV file
  CSV.open('solana_validator_ping_times.csv', 'a') do |csv|
    nodes.each do |k,v|
      csv << [my_address,
              my_ip,
              k,
              v[:ip],
              (v[:min_ms].nil?  ? '' : sprintf('%.2f', v[:min_ms])),
              (v[:avg_ms].nil?  ? '' : sprintf('%.2f', v[:avg_ms])),
              (v[:max_ms].nil?  ? '' : sprintf('%.2f', v[:max_ms])),
              (v[:mdev_ms].nil? ? '' : sprintf('%.2f', v[:mdev_ms])),
              v[:timestamp]]
    end
  end

  # write overall stats to a separate CSV file
  CSV.open('solana_network_stats.csv', 'a') do |csv|
    csv << [my_address,
            my_ip,
            overall_min_time,
            overall_average_time,
            overall_max_time,
            bandwidth_in,
            bandwidth_out,
            overall_timestamp]
  end

  puts ''
  puts "Overall Average Ping Time: #{sprintf('%.2f', overall_average_time)}"
  puts "Bandwidth KB/s In:         #{bandwidth_in}"
  puts "Bandwidth KB/s Out:        #{bandwidth_out}"
  puts ''
  puts 'Footnotes:'
  puts '  Ping times in ms.'
  puts '  Ping non-responders excluded from the average ping time.'
  puts ''

  end_time = Time.now

  puts "Ran from #{start_time} to #{end_time} for a total of #{end_time - start_time} seconds."
rescue StandardError => e
  puts ''
  puts e.class
  puts e.message
  puts e.backtrace
  puts ''
end # begin
