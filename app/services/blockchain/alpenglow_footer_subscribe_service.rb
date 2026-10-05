# frozen_string_literal: true

module Blockchain
  class AlpenglowFooterSubscribeService
    PING_ID = 1
    KEEPALIVE_TIME_MS = 30_000
    REQUEST_POLL_INTERVAL = 0.2 # seconds

    def initialize(network: "alpenglow-community", grpc_url:, token:)
      require "geyser_services_pb"
      @network = network
      @grpc_url = grpc_url
      @token = token
      log_path = Rails.root.join("log", "alpenglow_footer_subscribe_service_#{@network}.log")
      @logger = Logger.new(log_path)
    end

    def call(&block)
      requests = Queue.new
      requests << subscribe_request
      operation = nil
      call_finished = -> { !operation.nil? && (!operation.status.nil? || operation.cancelled?) }

      @logger.info("Subscribing to block footers at #{@grpc_url}")
      operation = geyser_stub.subscribe(
        request_stream(requests, call_finished),
        metadata: { "x-token" => @token },
        return_op: true
      )
      operation.execute.each do |update|
        case update.update_oneof
        when :block_footer
          handle_footer(update.block_footer, &block)
        when :ping
          requests << ping_request
        end
      end
      @logger.info("Stream from #{@grpc_url} closed")
    ensure
      requests&.close
      operation.cancel if operation && !call_finished.call
    end

    private

    def handle_footer(footer)
      yield Blockchain::AlpenglowFooterDecoder.new(footer).call
    rescue Blockchain::AlpenglowFooterDecoder::DecodeError => e
      @logger.error("Failed to decode footer for slot #{footer.slot}: #{e.message}")
    end

    def geyser_stub
      Geyser::Geyser::Stub.new(
        @grpc_url,
        GRPC::Core::ChannelCredentials.new,
        channel_args: { "grpc.keepalive_time_ms" => KEEPALIVE_TIME_MS }
      )
    end

    def request_stream(requests, call_finished)
      Enumerator.new do |stream|
        until requests.closed? || call_finished.call
          begin
            stream << requests.pop(true)
          rescue ThreadError
            sleep(REQUEST_POLL_INTERVAL)
          end
        end
      end
    end

    def subscribe_request
      Geyser::SubscribeRequest.new(
        block_footer: { "block_footer" => Geyser::SubscribeRequestFilterBlockFooter.new(include_certificates: true) },
        commitment: :PROCESSED
      )
    end

    def ping_request
      Geyser::SubscribeRequest.new(ping: Geyser::SubscribeRequestPing.new(id: PING_ID))
    end
  end
end
