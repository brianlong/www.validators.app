# frozen_string_literal: true

class AlpenglowClusterStatsQuery
  RECENT_EPOCHS = 10
  NOT_REPORTED = "Not reported"

  def initialize(network:, epoch: nil)
    @network = network
    @epoch = epoch
  end

  def epochs
    @epochs ||= scope.distinct.order(epoch: :desc).limit(RECENT_EPOCHS).pluck(:epoch)
  end

  def selected_epoch
    requested = @epoch.to_i if @epoch.present?
    epochs.include?(requested) ? requested : epochs.first
  end

  def call
    epoch = selected_epoch
    return nil if epoch.nil?

    rows = scope.where(epoch: epoch)
    leader_slots, with_final_cert, fast, slow, lag_sum = rows.pick(
      Arel.sql("SUM(leader_slots)"),
      Arel.sql("SUM(leader_slots_with_final_cert)"),
      Arel.sql("SUM(leader_fast_finalized)"),
      Arel.sql("SUM(leader_slow_finalized)"),
      Arel.sql("SUM(leader_final_lag_sum)")
    ).map(&:to_i)
    finalized = fast + slow

    {
      epoch: epoch,
      leaders: rows.where("leader_slots > 0").count,
      leader_slots: leader_slots,
      finalized_blocks: finalized,
      fast_finalized: fast,
      slow_finalized: slow,
      fast_percent: percent(fast, finalized),
      slow_percent: percent(slow, finalized),
      average_final_lag: finalized.positive? ? lag_sum.to_f / finalized : nil,
      final_cert_percent: percent(with_final_cert, leader_slots),
      clients: clients(rows, leader_slots),
      updated_at: rows.maximum(:updated_at)
    }
  end

  private

  def scope
    AlpenglowValidatorEpochStat.where(network: @network)
  end

  def percent(part, total)
    total.positive? ? 100.0 * part / total : nil
  end

  def clients(rows, total_slots)
    rows.where("leader_slots > 0").pluck(:last_block_user_agent, :leader_slots)
        .group_by { |user_agent, _| client_name(user_agent) }
        .map do |client, entries|
          slots = entries.sum { |_, count| count }
          {
            client: client,
            leaders: entries.size,
            leader_slots: slots,
            leader_slots_percent: percent(slots, total_slots),
            versions: sort_versions(entries.filter_map { |user_agent, _| client_version(user_agent) }.uniq)
          }
        end
        .sort_by { |client| -client[:leader_slots] }
  end

  def client_name(user_agent)
    return NOT_REPORTED if user_agent.blank?

    user_agent[/client:([^;)\s]+)/, 1] || user_agent[%r{\A[^/\s]+}]
  end

  def sort_versions(versions)
    versions.sort_by { |version| Gem::Version.correct?(version) ? Gem::Version.new(version) : Gem::Version.new("0") }.reverse
  end

  def client_version(user_agent)
    user_agent.to_s[%r{\A[^/\s]+/(\S+)}, 1]
  end
end
