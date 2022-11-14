# frozen_string_literal: true

EpochWallClock.delete_all

def solana_rpc_client(network)
  @solana_rpc_client ||= SolanaRpcClient.new
   
  return @solana_rpc_client.testnet_client if Rails.env.test?

  @solana_rpc_client.network_client(network)
end

NETWORKS.each do |network|
  slots_in_epoch = 432000

  last_epoch = solana_rpc_client(network).get_epoch_info.result

  puts last_epoch
  last_epoch_start_slot = last_epoch['absoluteSlot'] - last_epoch['slotIndex']

  slot_set = last_epoch_start_slot.to_i
  current_epoch = last_epoch['epoch']

  last_epoch['epoch'].times do
    slot_set -= slots_in_epoch
    current_epoch -= 1
    confirmed_start_block = nil

    100.times do |block_offset|
      puts block_offset

      slot = slot_set + block_offset
      get_block_result = solana_rpc_client(network).get_block(slot).result

      confirmed_start_block = slot unless get_block_result&.blank?

      break if confirmed_start_block
      sleep(0.1)
    rescue SolanaRpcRuby::ApiError
      next
    end

    break unless confirmed_start_block

    block_time = solana_rpc_client(network).get_block_time(confirmed_start_block).result.to_s

    last_epoch_start_datetime = DateTime.strptime(block_time, '%s')

    confirmed_end_block = nil
    100.times do |block_offset|
      slot = slot_set + slots_in_epoch - block_offset
      get_block_result = solana_rpc_client(network).get_block(slot).result
      
      confirmed_end_block = slot unless get_block_result&.blank?

      break if confirmed_end_block
    rescue SolanaRpcRuby::ApiError
      next
    end

    break unless confirmed_end_block

    puts "confirmed block: #{confirmed_start_block}"

    current_epoch_start_unix = solana_rpc_client(network).get_block_time(confirmed_start_block).result

    next unless current_epoch_start_unix
    puts current_epoch_start_unix
    current_epoch_created_at = DateTime.strptime(current_epoch_start_unix.to_s, '%s')

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
  puts "#{network} is done"
end
