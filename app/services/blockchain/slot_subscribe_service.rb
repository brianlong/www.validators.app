#frozen_string_literal: true

require "faye/websocket"
require 'eventmachine'

KEEPALIVE_TIME = 5
MAX_RETRIES = 5

module Blockchain
  class SlotSubscribeService

    def initialize(network: "mainnet", rpc_url:)
      @network = network
      @rpc_url = rpc_url.chomp("/")
      @retires = 0
      log_path = Rails.root.join("log", "slot_subscribe_service_#{@network}.log")
      @logger = @logger ||= Logger.new(log_path)
      @request_body = {id: rand(1..99_999), jsonrpc: "2.0", method: "slotSubscribe", params: []}.to_json
    end

    def call
      event_machine = EM.run {
        @retries = 0
        ws = Faye::WebSocket::Client.new(ws_url, nil)
      
        connection_test = EM::PeriodicTimer.new(KEEPALIVE_TIME) do
          @logger.info("ping...")
          while !ws&.ping
            @retries += 1

            unless @retries <= MAX_RETRIES
              @logger.error("Max retries (#{MAX_RETRIES}) reached, closing connection")
              ws&.close
              EventMachine::stop_event_loop
            end
      
            @logger.error("Ping failed, retrying in #{@retries} seconds...")
            sleep @retries
          end
        end
      
        ws.on :open do |event|
          @logger.info("Opened connection to #{ws_url}")
          @logger.info("Sending request: #{@request_body}")
          ws.send(@request_body)
        end
      
        ws.on :message do |event|
          @retries = 0
          data = JSON.parse(event.data)["params"]
          @logger.info("Received message: #{data}")
        end
      
        ws.on :close do |event|
          @logger.info("Closed connection to #{ws_url}")
          @logger.info("Code: #{event.code}, Reason: #{event.reason}")

          ws = nil
          EventMachine::stop_event_loop
        end
      
        ws.on :error do |event|
          @logger.error("Error: #{event.message}")
        end
      }
    end

    def ws_url
      if @ws_url
        @ws_url
      else
        ws_url = if @rpc_url.start_with?("ws://")
          @rpc_url
        elsif @rpc_url.start_with?("https://")
          @rpc_url.gsub("https", "ws")
        else
          "ws://#{@rpc_url}"
        end
        @ws_url = ws_url.end_with?(":8900") ? ws_url : "#{ws_url}:8900"
      end
    end
  end
end
