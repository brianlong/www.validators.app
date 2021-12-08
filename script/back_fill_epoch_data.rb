# frozen_string_literal: true

require 'uri'
require 'net/http'

EpochWallClock.delete_all

@common_params = {
  "jsonrpc" => "2.0", 
  "id" => 1
}

def get_last_epoch(http, uri)
  params = @common_params.merge( {
    "method" => "getEpochInfo"
  })
  resp, _ = http.post(uri, params.to_json, { 'Content-Type' => 'application/json' } )
  JSON.parse(resp.body)['result']
end

def get_block_time(http, uri, block)
  params = @common_params.merge( {
    "method" => "getBlockTime",
    "params" => [block]
  })
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  puts JSON.parse(resp.body)
  JSON.parse(resp.body)['result']
end

def get_confirmed_block(http, uri, slot)
  params = @common_params.merge( {
    "method" => "getConfirmedBlock", #TODO: This method is deprecated from solana 1.7
    "params" => [slot]
  })
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result'] ? slot : nil
end

%w[testnet mainnet].each do |network|
  url = if network == 'mainnet'
    Rails.application.credentials.solana[:mainnet_urls][0]
  else
    Rails.application.credentials.solana[:testnet_urls][0]
  end

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  slots_in_epoch = 432000

  last_epoch = get_last_epoch(http, uri)
  last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']

  slot_set = last_epoch_start_slot.to_i
  current_epoch = last_epoch['epoch']

  last_epoch['epoch'].times do
    slot_set -= slots_in_epoch
    current_epoch -= 1
    confirmed_start_block = nil
    100.times do |block_offset|
      puts block_offset
      confirmed_start_block = get_confirmed_block(http, uri, slot_set + block_offset)
      break if confirmed_start_block
      sleep(0.1)
    end

    break unless confirmed_start_block

    last_epoch_start_datetime = DateTime.strptime(get_block_time(http, uri, last_epoch_start_slot).to_s, '%s')

    confirmed_end_block = nil
    100.times do |block_offset|
      confirmed_end_block = get_confirmed_block(http, uri, slot_set + slots_in_epoch - block_offset)

      break if confirmed_end_block
    end

    break unless confirmed_end_block

    puts "confirmed block: #{confirmed_start_block}"

    current_epoch_start_unix = get_block_time(http, uri, confirmed_start_block).to_s

    next unless current_epoch_start_unix

    current_epoch_created_at = DateTime.strptime(current_epoch_start_unix, '%s')

    ewc = EpochWallClock.create(
      epoch: current_epoch,
      network: network,
      starting_slot: confirmed_start_block,
      slots_in_epoch: slots_in_epoch,
      created_at: current_epoch_created_at,
      ending_slot: confirmed_end_block
    )
    puts ewc.inspect
    sleep(1)
  end
end
