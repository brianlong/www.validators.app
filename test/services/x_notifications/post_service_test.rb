# frozen_string_literal: true

require "test_helper"

module XNotifications
  class PostServiceTest < ActiveSupport::TestCase
    class FakeClient
      attr_reader :posts

      def initialize(configured: true, error: nil)
        @configured = configured
        @error = error
        @posts = []
      end

      def configured?
        @configured
      end

      def create_post(text:, in_reply_to: nil)
        raise @error if @error

        @posts << { text: text, in_reply_to: in_reply_to }
        "x-#{@posts.size}"
      end
    end

    def build_service(**options)
      PostService.new(
        **{
          kind: :delinquency_started,
          network: "mainnet",
          reference_key: "key-1",
          message: "hello"
        }.merge(options)
      )
    end

    test "does nothing when kind is disabled" do
      assert_nil build_service(enabled_kinds: { delinquency_started: false }).call
      assert_equal 0, XPost.count
    end

    test "does nothing when network is not enabled" do
      assert_nil build_service(network: "testnet").call
      assert_equal 0, XPost.count
    end

    test "saves dry run post when not in live environment" do
      client = FakeClient.new
      x_post = build_service(client: client).call

      assert_equal "dry_run", x_post.status
      assert_equal "hello", x_post.message
      assert_empty client.posts
    end

    test "does not duplicate post with the same reference key" do
      build_service.call

      assert_nil build_service.call
      assert_equal 1, XPost.count
    end

    test "truncates message to max post length" do
      x_post = build_service(message: "a" * 500).call

      assert_equal X_POST_MAX_LENGTH, x_post.message.length
    end

    test "publishes post as reply to parent in live environment" do
      parent = XPost.create!(reference_key: "parent", status: "posted", x_post_id: "999")
      client = FakeClient.new

      Rails.env.stub(:in?, true) do
        x_post = build_service(client: client, parent: parent).call

        assert_equal "posted", x_post.status
        assert_equal "x-1", x_post.x_post_id
        assert_equal [{ text: "hello", in_reply_to: "999" }], client.posts
      end
    end

    test "marks post as failed when client raises error" do
      client = FakeClient.new(error: XClient::XResponseError.new("402: CreditsDepleted"))

      Rails.env.stub(:in?, true) do
        x_post = build_service(client: client).call

        assert_equal "failed", x_post.status
        assert_equal "402: CreditsDepleted", x_post.error
      end
    end
  end
end
