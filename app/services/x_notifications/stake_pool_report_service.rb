# frozen_string_literal: true

module XNotifications
  class StakePoolReportService
    include Formatting

    STAKE_COLUMNS = %i[stake_pubkey stake_pool_id validator_id delegated_stake deactivation_epoch].freeze

    def initialize(network:, post_service: PostService)
      @network = network
      @post_service = post_service
    end

    def call
      return unless @network.in?(X_NOTIFICATIONS_NETWORKS)

      epoch = StakeAccount.where(network: @network).maximum(:epoch)
      return unless epoch

      reference_key = "stake_pool_epoch_report:#{@network}:#{epoch}"
      return if XPost.exists?(reference_key: reference_key)

      changes = pool_changes(epoch)
      return if changes.empty?

      @post_service.new(
        kind: :stake_pool_epoch_report,
        network: @network,
        reference_key: reference_key,
        metadata: { "epoch" => epoch },
        message: message(epoch, changes)
      ).call
    end

    private

    def pool_changes(epoch)
      current = stake_by_pool_and_validator(StakeAccount.where(network: @network, epoch: epoch))
      previous = stake_by_pool_and_validator(StakeAccountHistory.where(network: @network, epoch: epoch - 1))
      return [] if previous.empty?

      min_change = X_STAKE_POOL_MIN_CHANGE_SOL * LAMPORTS_PER_SOL
      diffs_by_pool = (current.keys | previous.keys).group_by(&:first).transform_values do |keys|
        keys.map { |key| current.fetch(key, 0) - previous.fetch(key, 0) }
      end

      StakePool.where(id: diffs_by_pool.keys).filter_map do |pool|
        added = diffs_by_pool[pool.id].select { |diff| diff >= min_change }
        removed = diffs_by_pool[pool.id].select { |diff| diff <= -min_change }
        next if added.empty? && removed.empty?

        { pool: pool, added: added, removed: removed }
      end.sort_by { |change| -(change[:added].sum - change[:removed].sum) }
    end

    def stake_by_pool_and_validator(scope)
      scope.where.not(stake_pool_id: nil)
           .where.not(validator_id: nil)
           .pluck(*STAKE_COLUMNS)
           .uniq(&:first)
           .each_with_object(Hash.new(0)) do |(_pubkey, pool_id, validator_id, delegated_stake, deactivation_epoch), stakes|
             stakes[[pool_id, validator_id]] += deactivation_epoch.nil? ? delegated_stake.to_i : 0
           end
    end

    def message(epoch, changes)
      items = changes.map do |change|
        parts = []
        if change[:added].any?
          parts << "+#{format_sol(change[:added].sum)} SOL to #{change[:added].size} #{'validator'.pluralize(change[:added].size)}"
        end
        if change[:removed].any?
          parts << "−#{format_sol(-change[:removed].sum)} SOL from #{change[:removed].size} #{'validator'.pluralize(change[:removed].size)}"
        end

        "#{change[:pool].name}: #{parts.join(', ')}"
      end

      join_within_limit("Epoch #{epoch} stake pool report\n\n", items, separator: "\n")
    end
  end
end
