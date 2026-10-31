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
    totals = leader_totals(rows)
    leader_slots = totals[:leader_slots]
    fast = totals[:leader_fast_finalized]
    slow = totals[:leader_slow_finalized]
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
      average_final_lag: finalized.positive? ? totals[:leader_final_lag_sum].to_f / finalized : nil,
      final_cert_percent: percent(totals[:leader_slots_with_final_cert], leader_slots),
      updated_at: rows.maximum(:updated_at)
    }
  end

  private

  def scope
    AlpenglowValidatorEpochStat.for_network(@network)
  end

  def leader_totals(rows)
    counters = Blockchain::AlpenglowEpochStats::LEADER_COUNTERS
    sums = rows.select(counters.map { |counter| "COALESCE(SUM(#{counter}), 0) AS #{counter}" }).take
    counters.index_with { |counter| sums[counter].to_i }
  end

  def percent(part, total)
    total.positive? ? 100.0 * part / total : nil
  end
end
