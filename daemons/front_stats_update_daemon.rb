# frozen_string_literal: true

require_relative "../config/environment"

LEADERS_LIMIT = 6

def broadcast_leaders
    current_slot = solana_client.get_slot.result
    leader_accounts = solana_client.get_slot_leaders(current_slot, 20).result
    leaders = Validator.where(account: leader_accounts)
    leaders_mapped = leaders.map do |leader|
      { name: leader.name, avatar_url: leader.avatar_url }
    end

    print leaders_mapped
    ActionCable.server.broadcast("leaders_channel", leaders_mapped.take(LEADERS_LIMIT))
end

def solana_client
  @solana_client ||=
    cluster_url = Rails.application.credentials.solana[:mainnet_urls].first
    SolanaRpcRuby::MethodsWrapper.new(
      cluster: Rails.application.credentials.solana[:mainnet_urls].first
    )
end

loop do
  begin
    ftx_response = FtxClient.new.get_market
    parsed_response = JSON.parse(ftx_response.body)
    print parsed_response
    ActionCable.server.broadcast("sol_price_channel", parsed_response)

    broadcast_leaders
    sleep(5)
  rescue
    sleep(5)
    next
  end
end
