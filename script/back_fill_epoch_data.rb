# frozen_string_literal: true

# %w[mainnet testnet].each do |network|
#   epochs = EpochHistory.where(network: network)
#                        .where('created_at >= ?', Date.today.beginning_of_year)
#                        .pluck(:epoch).uniq

#   epochs.each do |epoch|
#     first_in_history = EpochHistory.where(epoch: epoch, network: network)
#                                    .order(created_at: :desc)
#                                    .last

#     EpochWallClock.find_or_create_by(epoch: epoch, network: network) do |e|
#       e.network = network
#       e.starting_slot = first_in_history.current_slot
#       e.slots_in_epoch = first_in_history.slots_in_epoch
#       e.ending_slot = first_in_history.current_slot - first_in_history.slots_in_epoch
#       e.created_at = first_in_history.created_at
#       puts 'created new EWC'
#     end

#     puts first_in_history.inspect
#   end
# end


require 'uri'
require 'net/http'

EpochWallClock.delete_all

def get_last_epoch(http, uri)
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getEpochInfo"
  }
  resp, _ = http.post(uri, params.to_json, { 'Content-Type' => 'application/json' } )
  JSON.parse(resp.body)['result']
end

def get_block_time(http, uri, block)
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getBlockTime",
    "params" => [block]
  }
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result']
end

def get_confirmed_block(http, uri, slot)
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getConfirmedBlock", #TODO: This method is deprecated from solana 1.7
    "params" => [slot]
  }
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result'] ? slot : nil
end

%w[testnet mainnet].each do |network|
  url = network == 'mainnet' ? 'https://api.mainnet-beta.solana.com' : 'https://api.testnet.solana.com'
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  slots_in_epoch = 432000

  last_epoch = get_last_epoch(http, uri)
  last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']
  last_epoch_start_datetime = DateTime.strptime(get_block_time(http, uri, last_epoch_start_slot).to_s, '%s')

  slot_set = last_epoch_start_slot.to_i
  current_epoch = last_epoch['epoch']

  last_epoch['epoch'].times do |i|
    slot_set = slot_set - slots_in_epoch
    current_epoch = current_epoch - 1
    confirmed_start_block = nil
    100.times do |b_diff|
      puts b_diff
      confirmed_start_block = get_confirmed_block(http, uri, slot_set + b_diff)
      break if confirmed_start_block
      sleep(0.1)
    end

    break unless confirmed_start_block

    confirmed_end_block = nil
    100.times do |b_diff|
      confirmed_end_block = get_confirmed_block(http, uri, slot_set + slots_in_epoch - b_diff)
      break if confirmed_end_block
    end

    break unless confirmed_end_block

    current_epoch_start_unix =  get_block_time(http, uri, confirmed_start_block).to_s
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