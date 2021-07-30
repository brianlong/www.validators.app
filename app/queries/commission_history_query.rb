# frozen_string_literal: true

class CommissionHistoryQuery
  QUERY_FIELDS = 'commission_histories.created_at,
                  commission_before,
                  commission_after,
                  epoch,
                  commission_histories.network,
                  validator_id,
                  validators.account'

  def initialize(network:, query:, time_range:)
    @network = network
    @time_range = time_range
    @query = query
  end

  def call
    # If query is present, search for matching validators, 
    # otherwise take all records from a time range
    if @query
      validators_ids = matching_validators.pluck(:id)

      commission_histories = CommissionHistory.joins(:validator)
                                              .select(QUERY_FIELDS)
                                              .where(
                                                network: @network,
                                                created_at: @time_range,
                                                validator_id: validators_ids
                                              )
    else
      commission_histories = CommissionHistory.joins(:validator)
                                              .select(QUERY_FIELDS)
                                              .where(
                                                network: @network,
                                                created_at: @time_range
                                              )
    end

    commission_histories
  end

  private

  def matching_validators
    validators = Validator.where(network: @network)
                          .scorable
                          .joins(:validator_score_v1)

    ValidatorSearchQuery.new(validators)
                        .search(@query)
  end
end
