# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

def solana_rpc_client(network)
  @solana_rpc_client ||= SolanaRpcClient.new
  network = 'testnet' if Rails.env.test?

  @solana_rpc_client.network_client(network)
end

NETWORKS.each do |network|
  slots_in_epoch = 432000

  # number of slots to search for a confirmed block
  block_search_count = 100

  last_epoch = solana_rpc_client(network).get_epoch_info.result

  last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']

  next if EpochWallClock.where(network: network).find_by(epoch: last_epoch['epoch'])

  confirmed_start_block = nil
  block_time = nil
  block_search_count.times do |b_diff|
    slot = last_epoch_start_slot + b_diff
    
    get_block_result = solana_rpc_client(network).get_block(slot).result

    confirmed_start_block = slot unless get_block_result&.blank?
    next unless confirmed_start_block

    # We need to check block time since it may happen that timestamp is not available for this block
    block_time = solana_rpc_client(network).get_block_time(confirmed_start_block).result.to_s
    if block_time.present?
      break
    else
      confirmed_start_block = nil
    end

  # when block is not confirmed, rpc returns error
  # we want to skip this slot and try with another one
  rescue SolanaRpcRuby::ApiError, JSON::ParserError
    next
  end

  last_epoch_start_datetime = DateTime.strptime(block_time, "%s")

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
    slot = last_epoch_start_slot - 1 - b_diff

    get_block_result = solana_rpc_client(network).get_block(slot).result

    confirmed_end_block = slot unless get_block_result&.blank?

    break if confirmed_end_block
  # when block is not confirmed, rpc returns error
  # we want to skip this slot and try with another one
  rescue SolanaRpcRuby::ApiError
    next
  end

  break unless confirmed_end_block

  EpochWallClock.where(network: network)
                .find_by(epoch: last_epoch['epoch'].to_i - 1)
                &.update(ending_slot: confirmed_end_block)
end
