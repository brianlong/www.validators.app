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

@uri = URI('https://dus1.rpcpool.com')
@http = Net::HTTP.new(@uri.host, @uri.port)
@http.use_ssl = true

def get_last_epoch
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getEpochInfo"
  }
  resp, _ = @http.post(@uri, params.to_json, { 'Content-Type' => 'application/json' } )
  JSON.parse(resp.body)['result']
end

def get_block_time(block)
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getBlockTime", 
    "params" => [block]
  }
  resp, _ = @http.post(@uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result']
end

def get_confirmed_block(slot)
  params = {
    "jsonrpc" => "2.0", 
    "id" => 1, 
    "method" => "getConfirmedBlock", 
    "params" => [slot]
  }
  resp, _ = @http.post(@uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result'] ? slot : nil
end

slots_in_epoch = 432000

last_epoch = get_last_epoch()
last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']
last_epoch_start_datetime = DateTime.strptime(get_block_time(last_epoch_start_slot).to_s, '%s')

slot_set = last_epoch_start_slot.to_i
current_epoch = last_epoch['epoch']

last_epoch['epoch'].times do |i|
  slot_set = slot_set - slots_in_epoch
  current_epoch = current_epoch - 1
  confirmed_start_block = nil
  50.times do |b_diff|
    confirmed_start_block = get_confirmed_block(slot_set + b_diff)
    break if confirmed_start_block
  end

  break unless confirmed_start_block

  confirmed_end_block = nil
  50.times do |b_diff|
    confirmed_end_block = get_confirmed_block(slot_set + slots_in_epoch - b_diff)
    break if confirmed_end_block
  end

  break unless confirmed_end_block

  current_epoch_start_unix =  get_block_time(confirmed_start_block).to_s
  current_epoch_created_at = DateTime.strptime(current_epoch_start_unix, '%s')
  EpochWallClock.create(
    epoch: current_epoch, 
    network: "mainnet", 
    starting_slot: confirmed_start_block, 
    slots_in_epoch: slots_in_epoch, 
    created_at: current_epoch_created_at,
    ending_slot: confirmed_end_block
  )
  sleep(1)
end