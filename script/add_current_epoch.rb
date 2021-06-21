# frozen_string_literal: true

require 'uri'
require 'net/http'

require File.expand_path('../config/environment', __dir__)

@common_params = {
  "jsonrpc" => "2.0", 
  "id" => 1
}

def get_last_epoch(http, uri)
  params = @common_params.merge( {
    "method" => "getEpochInfo"
  } )
  resp, _ = http.post(uri, params.to_json, { 'Content-Type' => 'application/json' } )
  JSON.parse(resp.body)['result']
end

def get_block_time(http, uri, block)
  params = @common_params.merge( {
    "method" => "getBlockTime",
    "params" => [block]
  } )
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result']
end

def get_confirmed_block(http, uri, slot)
  params = @common_params.merge( {
    "method" => "getConfirmedBlock", #TODO: This method is deprecated from solana 1.7
    "params" => [slot]
  } )
  resp, _ = http.post(uri, params.to_json, {'Content-Type' => 'application/json'})
  JSON.parse(resp.body)['result'] ? slot : nil
end

%w[mainnet testnet].each do |network|
  if Rails.env.test?
    url = 'https://api.testnet.solana.com'
  else
    url = if network == 'mainnet'
      Rails.application.credentials.solana[:mainnet_urls][0]
    else
      Rails.application.credentials.solana[:testnet_urls][0]
    end
  end

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  slots_in_epoch = 432000

  # number of slots to search for a confirmed block
  block_search_count = 100

  last_epoch = get_last_epoch(http, uri)
  last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']
  last_epoch_start_datetime = DateTime.strptime(get_block_time(http, uri, last_epoch_start_slot).to_s, '%s')

  next if EpochWallClock.where(network: network).find_by(epoch: last_epoch['epoch'])

  confirmed_start_block = nil
  block_search_count.times do |b_diff|
    confirmed_start_block = get_confirmed_block(http, uri, last_epoch_start_slot + b_diff)
    break if confirmed_start_block
  end

  break unless confirmed_start_block

  created_epoch = EpochWallClock.create(
    epoch: last_epoch['epoch'],
    network: network,
    starting_slot: confirmed_start_block,
    slots_in_epoch: slots_in_epoch,
    created_at: last_epoch_start_datetime,
    ending_slot: nil
  )

  Rails.logger.warn "created new epoch #{created_epoch.epoch}"

  confirmed_end_block = nil
  block_search_count.times do |b_diff|
    confirmed_end_block = get_confirmed_block(http, uri, last_epoch_start_slot - 1 - b_diff)
    break if confirmed_end_block
  end
  break unless confirmed_end_block
  EpochWallClock.where(network: network)
                .find_by(epoch: last_epoch['epoch'].to_i - 1)
                &.update(ending_slot: confirmed_end_block)
end
