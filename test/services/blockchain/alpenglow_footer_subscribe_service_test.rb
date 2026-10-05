# frozen_string_literal: true

require "test_helper"
require "geyser_services_pb"

module Blockchain
  class AlpenglowFooterSubscribeServiceTest < ActiveSupport::TestCase
    class FakeOperation
      attr_reader :status, :sent_requests

      def initialize(requests, updates)
        @requests = requests
        @updates = updates
        @sent_requests = []
        @status = nil
        @cancelled = false
      end

      def execute
        Enumerator.new do |stream|
          writer = Thread.new { @requests.each { |request| @sent_requests << request } }
          @updates.each { |update| stream << update }
          sleep(0.3)
          @status = :ok
          writer.join
        end
      end

      def cancel
        @cancelled = true
      end

      def cancelled?
        @cancelled
      end
    end

    class FakeStub
      attr_reader :operation

      def initialize(updates)
        @updates = updates
      end

      def subscribe(requests, metadata:, return_op:)
        @operation = FakeOperation.new(requests, @updates)
      end
    end

    setup do
      data = JSON.parse(file_fixture("alpenglow_footers.json").read)["fast"]
      footer = Geyser::SubscribeUpdateBlockFooter.new(
        slot: data["slot"],
        block_user_agent: data["block_user_agent"].b,
        block_final_cert: [data["block_final_cert"]].pack("H*")
      )
      @updates = [
        Geyser::SubscribeUpdate.new(block_footer: footer),
        Geyser::SubscribeUpdate.new(ping: Geyser::SubscribeUpdatePing.new)
      ]
      @service = Blockchain::AlpenglowFooterSubscribeService.new(
        network: "alpenglow-community", grpc_url: "localhost:443", token: "token"
      )
    end

    test "#call yields decoded footers and finishes when the server closes the stream" do
      fake_stub = FakeStub.new(@updates)
      footers = []

      @service.stub(:geyser_stub, fake_stub) do
        Timeout.timeout(5) { @service.call { |footer| footers << footer } }
      end

      assert_equal [@updates.first.block_footer.slot], footers.map { |footer| footer[:slot] }
      assert_equal "fast", footers.first[:block_final_cert][:finalization]
      sent = fake_stub.operation.sent_requests
      assert sent.first.block_footer["block_footer"].include_certificates
      assert sent.any?(&:ping), "expected a ping response to be sent"
    end
  end
end
