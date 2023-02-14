# frozen_string_literal: true

class CommissionHistoryQuery
  TIME_RANGE_AGO = 60.days.ago

  CH_FIELDS = %w[
    created_at
    commission_before
    commission_after
    epoch
    network
    validator_id
    id
    epoch_completion
    batch_uuid
    from_inflation_rewards
  ].freeze

  VAL_FIELDS = %w[
    account
    name
  ].freeze

  def initialize(options)
    @network = options.fetch(:network, 'testnet')
    @time_from = options.fetch(:time_from, TIME_RANGE_AGO) || TIME_RANGE_AGO
    @time_to = options.fetch(:time_to, DateTime.now) || DateTime.now
    @time_range = @time_from..@time_to
    @sort_by = options.fetch(:sort_by, 'timestamp_desc') || 'timestamp_desc'
  end

  def all_records
    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(
                                              network: @network,
                                              created_at: @time_range
                                            )
    sorted(commission_histories)
  end

  def by_query(query = nil)
    validators_ids = matching_validators(query).pluck(:id)

    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(
                                              network: @network,
                                              created_at: @time_range,
                                              validator_id: validators_ids
                                            )
    sorted(commission_histories)
  end

  def exists_for_validator?(validator_id)
    CommissionHistory.where(
      network: @network,
      created_at: @time_range,
      validator_id: validator_id
    ).exists?
  end

  private

  def sorted(commission_histories)
    case @sort_by
    when 'epoch_desc'
      commission_histories.order(epoch: :desc)
    when 'epoch_asc'
      commission_histories.order(epoch: :asc)
    when 'timestamp_asc'
      commission_histories.order(created_at: :asc)
    when 'validator_asc'
      commission_histories.order(name: :asc)
    when 'validator_desc'
      commission_histories.order(name: :desc)
    else
      commission_histories.order(created_at: :desc)
    end
  end

  def matching_validators(query)
    validators = Validator.where(network: @network)
                          .joins(:validator_score_v1)
    ValidatorSearchQuery.new(validators).search(query)
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
