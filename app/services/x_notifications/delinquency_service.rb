# frozen_string_literal: true

module XNotifications
  class DelinquencyService
    include Formatting

    RESOLVED_LOOKBACK = 7.days

    def initialize(network:, post_service: PostService)
      @network = network
      @post_service = post_service
    end

    def call
      return unless @network.in?(X_NOTIFICATIONS_NETWORKS)

      notify_started
      notify_resolved
    end

    private

    def notify_started
      delinquent_validators.each do |validator|
        since = delinquent_since(validator)
        next unless since
        next if since > X_DELINQUENCY_MIN_MINUTES.minutes.ago
        next if since < X_DELINQUENCY_MAX_AGE_HOURS.hours.ago

        @post_service.new(
          kind: :delinquency_started,
          network: @network,
          validator: validator,
          reference_key: "delinquency_started:#{validator.id}:#{since.to_i}",
          metadata: { "delinquent_since" => since.iso8601 },
          message: "#{validator_label(validator)} has stopped voting. " \
                   "Delinquent for #{format_duration(Time.current - since)} " \
                   "with #{format_sol(validator.active_stake)} SOL delegated."
        ).call
      end
    end

    def notify_resolved
      unresolved_started_posts.each do |started_post|
        validator = started_post.validator
        next if validator.nil? || validator.delinquent?

        since = Time.zone.parse(started_post.metadata["delinquent_since"])

        @post_service.new(
          kind: :delinquency_resolved,
          network: @network,
          validator: validator,
          parent: started_post,
          reference_key: "delinquency_resolved:#{started_post.id}",
          message: "#{validator_label(validator)} is voting again after #{format_duration(Time.current - since)}."
        ).call
      end
    end

    def delinquent_validators
      Validator.joins(:validator_score_v1)
               .includes(:validator_score_v1)
               .where(network: @network, validator_score_v1s: { delinquent: true })
               .where("validator_score_v1s.active_stake >= ?", X_DELINQUENCY_MIN_STAKE_SOL * LAMPORTS_PER_SOL)
    end

    def delinquent_since(validator)
      histories = ValidatorHistory.where(network: @network, account: validator.account)
      last_voting_at = histories.where(delinquent: false).maximum(:created_at)
      return unless last_voting_at

      histories.where(delinquent: true).where("created_at > ?", last_voting_at).minimum(:created_at)
    end

    def unresolved_started_posts
      resolved_parent_ids = XPost.where(network: @network, kind: "delinquency_resolved").select(:parent_id)

      XPost.not_failed
           .where(network: @network, kind: "delinquency_started")
           .where("created_at > ?", RESOLVED_LOOKBACK.ago)
           .where.not(id: resolved_parent_ids)
           .includes(validator: :validator_score_v1)
    end
  end
end
