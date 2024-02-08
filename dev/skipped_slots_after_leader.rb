# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

batch_uuid = SecureRandom.uuid

# block_history_json = `solana block-production \
#                       --output json-compact \
#                       --url 'http://api.mainnet-beta.solana.com:8899'`
# block_history_json = File.read('block_production.json')
# solana:
#   mainnet_url: 'https://api.mainnet-beta.solana.com'
#   testnet_url: 'https://testnet.solana.com'
#   rpc_port: 8899
#
# Capture the block production into a JSON file, then process the
# file.
#
# `solana block-production  --output json-compact  --url 'https://api.mainnet-beta.solana.com:8899' > blocks_20200614.json`

block_history_json = File.read('blocks_20200614.json')
block_history = JSON.parse(block_history_json)

epoch = block_history['epoch']
total_slots = block_history['total_slots']
total_slots_skipped = block_history['total_slots_skipped']
total_slots_skipped_percent = (total_slots_skipped / total_slots.to_f) * 100.0

leaders_block = block_history['leaders']
validator_block_history = {}
leaders_block.each do |v|
  validator_block_history[v['identityPubkey']] = {
    'batch_uuid' => batch_uuid,
    'epoch' => epoch,
    'leader_slots' => v['leaderSlots'],
    'blocks_produced' => v['blocksProduced'],
    'skipped_slots' => v['skippedSlots'],
    'skipped_slot_percent' => v['skippedSlots'] / v['leaderSlots'].to_f,
    'skipped_slots_after_me' => 0,
    'skipped_slots_after_me_percent' => 0.0
  }
end

# puts block_history['individual_slot_status'][0..4].inspect
# Sample block history individual_slot_status
# [{"leader"=>"8NndwQsrH4f6xF6DW1tt7ESMEJpKz346AGqURKMXcNhT", "skipped"=>false, "slot"=>17372256}, {"leader"=>"8NndwQsrH4f6xF6DW1tt7ESMEJpKz346AGqURKMXcNhT", "skipped"=>false, "slot"=>17372257}, {"leader"=>"8NndwQsrH4f6xF6DW1tt7ESMEJpKz346AGqURKMXcNhT", "skipped"=>false, "slot"=>17372258}, {"leader"=>"8NndwQsrH4f6xF6DW1tt7ESMEJpKz346AGqURKMXcNhT", "skipped"=>false, "slot"=>17372259}, {"leader"=>"3FhfNWGiqDsy4xAXiS74WUb5GLfK7FVnn6kxt3CYLgvr", "skipped"=>false, "slot"=>17372260}]

# Look through the slots to accumulate stats
prior_leader = nil
current_leader = nil
i = 0
block_history['individual_slot_status'].each do |h|
  this_leader = h['leader']
  # puts "#{h['slot']} => #{this_leader}"
  if this_leader == current_leader
    # We have the same leader
  else
    # We have a new leader
    prior_leader = current_leader
    current_leader = this_leader
    # calculate the stats for the prior leader
    # The prior leaders slots ended at i-1
    # if /26AT/.match prior_leader
    #   puts "  PRIOR LEADER: #{prior_leader}"
    #   puts "  NEW LEADER: #{current_leader}"
    #   puts "  #{block_history['individual_slot_status'][i..i + 3].map { |s| s['skipped'] }}"
    # end
    skipped_slots_after_leader = \
      block_history['individual_slot_status'][i..i + 3].count do |s|
        s['skipped'] == true
      end
    # puts "  #{skipped_slots_after_leader}"

    if prior_leader.nil?
      i += 1
      next
    end

    validator_block_history[prior_leader]['skipped_slots_after_me'] += \
      skipped_slots_after_leader
  end

  i += 1
end

# Put some data to the console for logging
puts "EPOCH: #{epoch}"
puts "TOTAL SLOTS: #{total_slots}"
puts "TOTAL SKIPPED: #{total_slots_skipped}"
puts "TOTAL SKIPPED %: #{total_slots_skipped_percent}"
puts ''
puts [
  'Public ID'.ljust(11),
  'Slots'.ljust(9),
  'Skipped'.ljust(9),
  'Skipped %'.ljust(9),
  'Skipped'.ljust(9),
  'Skipped'.ljust(9)
].join(' | ')
puts [
  ' '.ljust(11),
  ' '.ljust(9),
  ' '.ljust(9),
  ' '.ljust(9),
  'After'.ljust(9),
  'After %'.ljust(9)
].join(' | ')
puts ['-' * 11, '-' * 9, '-' * 9, '-' * 9, '-' * 9, '-' * 9].join('-|-')

# TODO: sort by skipped after % descending
validator_block_history.sort_by { |_k, v| v['skipped_slots_after_me'] / v['leader_slots'].to_f }.reverse.to_h.each do |k, v|
  puts [
    "#{k[0..3]}...#{k[-4..-1]}".ljust(11),
    v['leader_slots'].to_s.rjust(9),
    v['skipped_slots'].to_s.rjust(9),
    format('%.2f', v['skipped_slot_percent'] * 100.0).rjust(9),
    v['skipped_slots_after_me'].to_s.rjust(9),
    format('%.2f', (v['skipped_slots_after_me'] / v['leader_slots'].to_f) * 100.0).rjust(9)
  ].join(' | ')
end
