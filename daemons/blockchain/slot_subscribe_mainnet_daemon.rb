# frozen_string_literal: true

require_relative "../../config/environment"

SLEEP_TIME = 1 #seconds

loop do
  begin
    Blockchain::SlotSubscribeService.new(
      network: "mainnet",
      rpc_url: Rails.application.credentials.solana[:mainnet_urls][0]
    ).call
  rescue => e
    puts e
    puts e.backtrace

    # restart ws connection after SLEEP_TIME
    sleep(SLEEP_TIME)
    next
  end
end
