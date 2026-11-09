# frozen_string_literal: true

module XNotifications
  class PostService
    def initialize(
      kind:,
      network:,
      reference_key:,
      message:,
      validator: nil,
      parent: nil,
      metadata: {},
      client: XClient.new,
      enabled_kinds: X_NOTIFICATIONS
    )
      @kind = kind.to_s
      @network = network
      @reference_key = reference_key
      @message = message
      @validator = validator
      @parent = parent
      @metadata = metadata
      @client = client
      @enabled_kinds = enabled_kinds
    end

    def call
      return unless @enabled_kinds[@kind.to_sym]
      return unless @network.in?(X_NOTIFICATIONS_NETWORKS)
      return if XPost.exists?(reference_key: @reference_key)

      x_post = XPost.create!(
        kind: @kind,
        network: @network,
        reference_key: @reference_key,
        message: @message.truncate(X_POST_MAX_LENGTH, omission: "…"),
        validator: @validator,
        parent: @parent,
        metadata: @metadata,
        status: "pending"
      )

      publish(x_post)
      x_post
    end

    private

    def publish(x_post)
      unless live?
        x_notifications_logger.info("[dry_run] #{x_post.kind}: #{x_post.message}")
        x_post.update!(status: "dry_run")
        return
      end

      x_post_id = @client.create_post(text: x_post.message, in_reply_to: @parent&.x_post_id)
      x_post.update!(status: "posted", x_post_id: x_post_id, posted_at: Time.current)
    rescue StandardError => e
      x_post.update!(status: "failed", error: e.message)
      x_notifications_logger.error("[failed] #{x_post.kind}: #{e.message}")
      Appsignal.send_error(e) if Rails.env.in?(%w[stage production])
    end

    def live?
      @client.configured? && Rails.env.in?(X_NOTIFICATIONS_LIVE_ENVIRONMENTS)
    end

    def x_notifications_logger
      log_path = File.join(Rails.root, "log", Rails.env)
      FileUtils.mkdir_p(log_path)

      @x_notifications_logger ||= Logger.new(File.join(log_path, "x_notifications.log"))
    end
  end
end
