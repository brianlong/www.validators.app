# frozen_string_literal: true

class AlpenglowClusterStatsQuery
  def initialize(network:, epoch: nil)
    @network = network
    @epoch = epoch
  end

  def epochs
    @epochs ||= AlpenglowValidatorEpochStat.recent_epochs(@network)
  end

  def selected_epoch
    @selected_epoch ||= AlpenglowValidatorEpochStat.resolve_epoch(@network, @epoch)
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
    AlpenglowValidatorEpochStat.for_network(@network)
  end

  def percent(part, total)
    total.positive? ? 100.0 * part / total : nil
  end

  def clients(rows, total_slots)
    rows.where("leader_slots > 0").pluck(:last_block_user_agent, :leader_slots)
        .group_by { |user_agent, _| Blockchain::AlpenglowUserAgent.client(user_agent) }
        .map do |client, entries|
          slots = entries.sum { |_, count| count }
          {
            client: client,
            leaders: entries.size,
            leader_slots: slots,
            leader_slots_percent: percent(slots, total_slots),
            versions: sort_versions(entries.filter_map { |user_agent, _| Blockchain::AlpenglowUserAgent.version(user_agent) }.uniq)
          }
        end
        .sort_by { |client| -client[:leader_slots] }
  end

  def sort_versions(versions)
    versions.sort_by { |version| Gem::Version.correct?(version) ? Gem::Version.new(version) : Gem::Version.new("0") }.reverse
  end
end
