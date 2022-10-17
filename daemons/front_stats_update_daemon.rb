# frozen_string_literal: true

require_relative "../config/environment"

loop do
  begin
    ftx_response = FtxClient.new.get_market
    parsed_response = JSON.parse(ftx_response.body)
    print parsed_response
    ActionCable.server.broadcast("sol_price_channel", parsed_response)
    sleep(5)
  rescue
    sleep(5)
    next
  end
end
