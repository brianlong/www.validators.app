# frozen_string_literal: true

module XNotifications
  class CommissionReportService
    include Formatting

    def initialize(network:, post_service: PostService)
      @network = network
      @post_service = post_service
    end

    def call
      return unless @network.in?(X_NOTIFICATIONS_NETWORKS)

      epoch = report_epoch
      return unless epoch

      reference_key = "commission_epoch_report:#{@network}:#{epoch}"
      return if XPost.exists?(reference_key: reference_key)

      increases = commission_increases(epoch)
      return if increases.empty?

      @post_service.new(
        kind: :commission_epoch_report,
        network: @network,
        reference_key: reference_key,
        metadata: { "epoch" => epoch },
        message: message(epoch, increases)
      ).call
    end

    private

    def report_epoch
      current_epoch = EpochWallClock.by_network(@network).first
      return unless current_epoch
      return if current_epoch.created_at > X_EPOCH_REPORT_DELAY_HOURS.hours.ago

      current_epoch.epoch - 1
    end

    def commission_increases(epoch)
      CommissionHistory.where(network: @network, epoch: epoch)
                       .where("commission_after - commission_before >= ?", X_COMMISSION_MIN_INCREASE)
                       .includes(validator: :validator_score_v1)
                       .group_by(&:validator)
                       .map do |validator, histories|
                         {
                           validator: validator,
                           before: histories.map(&:commission_before).min,
                           after: histories.map(&:commission_after).max
                         }
                       end
                       .sort_by { |increase| -increase[:validator].active_stake }
    end

    def message(epoch, increases)
      total_stake = increases.sum { |increase| increase[:validator].active_stake }
      items = increases.map do |increase|
        "#{validator_label(increase[:validator])} #{format_commission(increase[:before])} → #{format_commission(increase[:after])}"
      end

      join_within_limit(
        "Epoch #{epoch} commission report\n\n#{increases.size} commission #{'increase'.pluralize(increases.size)}: ",
        items,
        ". #{format_sol(total_stake)} SOL delegated to them."
      )
    end
  end
end
