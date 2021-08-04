# frozen_string_literal: true

class CommissionHistoryQuery
  QUERY_FIELDS = 'commission_histories.created_at,
                  commission_before,
                  commission_after,
                  epoch,
                  commission_histories.network,
                  validator_id,
                  validators.account'

  def initialize(options)
    @network = options.fetch(:network, 'testnet')
    @time_from = options.fetch(:time_from, 30.days.ago) || 30.days.ago
    @time_to = options.fetch(:time_to, DateTime.now) || DateTime.now
    @time_range = @time_from..@time_to
  end

  def all_records
    CommissionHistory.joins(:validator)
                     .select(QUERY_FIELDS)
                     .where(
                       network: @network,
                       created_at: @time_range
                     )
  end

  def by_query(query = nil)
    validators_ids = matching_validators(query).pluck(:id)

    CommissionHistory.joins(:validator)
                     .select(QUERY_FIELDS)
                     .where(
                       network: @network,
                       created_at: @time_range,
                       validator_id: validators_ids
                     )
  end

  private

  def matching_validators(query)
    validators = Validator.where(network: @network)
                          .scorable
                          .joins(:validator_score_v1)

    ValidatorSearchQuery.new(validators)
                        .search(query)
  end
end
