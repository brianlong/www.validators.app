# frozen_string_literal: true

class AlpenglowValidatorStatsQuery
  PER_PAGE = 25
  MAX_PER_PAGE = 100
  DEFAULT_SORT = "notar_participation"

  STATS_TABLE = AlpenglowValidatorEpochStat.table_name

  METRICS = {
    "notar_participation" => "#{STATS_TABLE}.notar_votes * 100.0 / NULLIF(#{STATS_TABLE}.notar_reward_slots, 0)",
    "fast_inclusion" => "#{STATS_TABLE}.fast_final_signatures * 100.0 / NULLIF(#{STATS_TABLE}.fast_finalized_slots, 0)",
    "slow_inclusion" => "#{STATS_TABLE}.slow_final_signatures * 100.0 / NULLIF(#{STATS_TABLE}.slow_finalized_slots, 0)",
    "leader_fast_percent" => "#{STATS_TABLE}.leader_fast_finalized * 100.0 / " \
                             "NULLIF(#{STATS_TABLE}.leader_fast_finalized + #{STATS_TABLE}.leader_slow_finalized, 0)",
    "average_final_lag" => "#{STATS_TABLE}.leader_final_lag_sum * 1.0 / " \
                           "NULLIF(#{STATS_TABLE}.leader_fast_finalized + #{STATS_TABLE}.leader_slow_finalized, 0)",
    "final_cert_percent" => "#{STATS_TABLE}.leader_slots_with_final_cert * 100.0 / NULLIF(#{STATS_TABLE}.leader_slots, 0)"
  }.freeze

  SORTS = (METRICS.keys + %w[skip_votes divergent_skip_votes leader_slots stake]).freeze

  def initialize(network:, epoch:, sort_by: nil, direction: nil, page: 1, per: PER_PAGE)
    @network = network
    @epoch = epoch
    @sort_by = SORTS.include?(sort_by) ? sort_by : DEFAULT_SORT
    @direction = direction.to_s.downcase == "asc" ? "ASC" : "DESC"
    @page = [page.to_i, 1].max
    @per = per.to_i.clamp(1, MAX_PER_PAGE)
  end

  def call
    records = scope.page(@page).per(@per)

    {
      epoch: @epoch,
      sort_by: @sort_by,
      direction: @direction.downcase,
      page: @page,
      per: @per,
      total_count: records.total_count,
      validators: records.map { |record| serialize(record) }
    }
  end

  private

  def scope
    AlpenglowValidatorEpochStat.where(network: @network, epoch: @epoch)
                               .joins(:validator, :vote_account)
                               .joins(ranks_join)
                               .select(select_columns)
                               .order(Arel.sql(order_clause))
  end

  def ranks_join
    <<~SQL.squish
      LEFT JOIN alpenglow_epoch_ranks ON alpenglow_epoch_ranks.network = #{STATS_TABLE}.network
        AND alpenglow_epoch_ranks.epoch = #{STATS_TABLE}.epoch
        AND alpenglow_epoch_ranks.vote_account = vote_accounts.account
        AND alpenglow_epoch_ranks.status <> #{AlpenglowEpochRank.statuses[:provisional]}
    SQL
  end

  def select_columns
    [
      "#{STATS_TABLE}.*",
      "validators.name AS validator_name",
      "validators.account AS validator_account",
      "vote_accounts.account AS vote_account_address",
      "alpenglow_epoch_ranks.stake AS stake",
      "alpenglow_epoch_ranks.rank AS epoch_rank",
      *METRICS.map { |name, expression| "#{expression} AS #{name}" }
    ].join(", ")
  end

  def order_clause
    column = %w[skip_votes divergent_skip_votes leader_slots].include?(@sort_by) ? "#{STATS_TABLE}.#{@sort_by}" : @sort_by
    "#{column} IS NULL, #{column} #{@direction}, stake IS NULL, stake DESC, #{STATS_TABLE}.id ASC"
  end

  def serialize(record)
    {
      validator_name: record.validator_name,
      validator_account: record.validator_account,
      vote_account: record.vote_account_address,
      stake: record.stake,
      rank: record.epoch_rank,
      notar_votes: record.notar_votes,
      notar_reward_slots: record.notar_reward_slots,
      skip_votes: record.skip_votes,
      divergent_skip_votes: record.divergent_skip_votes,
      leader_slots: record.leader_slots,
      client: Blockchain::AlpenglowUserAgent.client(record.last_block_user_agent),
      version: Blockchain::AlpenglowUserAgent.version(record.last_block_user_agent)
    }.merge(METRICS.keys.to_h { |name| [name.to_sym, record[name]&.to_f] })
  end
end
