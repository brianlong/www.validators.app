# frozen_string_literal: true

class CommissionHistoryQuery
  CH_FIELDS = %w[
    created_at
    commission_before
    commission_after
    epoch
    network
    validator_id
  ].freeze

  VAL_FIELDS = %w[account].freeze

  def initialize(options)
    @network = options.fetch(:network, 'testnet')
    @time_from = options.fetch(:time_from, 30.days.ago) || 30.days.ago
    @time_to = options.fetch(:time_to, DateTime.now) || DateTime.now
    @time_range = @time_from..@time_to
  end

  def all_records
    CommissionHistory.joins(:validator)
                     .select(query_fields)
                     .where(
                       network: @network,
                       created_at: @time_range
                     )
  end

  def by_query(query = nil)
    validators_ids = matching_validators(query).pluck(:id)

    CommissionHistory.joins(:validator)
                     .select(query_fields)
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

  def query_fields
    ch_fields = CH_FIELDS.map do |field|
      "commission_histories.#{field}"
    end.join(', ')

    val_fields = VAL_FIELDS.map do |field|
      "validators.#{field}"
    end.join(', ')

    [ch_fields, val_fields].join(', ')
  end
end
