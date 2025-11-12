# frozen_string_literal: true

class CommissionHistoryQuery
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
    source_from_rewards
  ].freeze

  VAL_FIELDS = %w[
    account
    name
  ].freeze

  def initialize(options)
    @network = options.fetch(:network, 'testnet')
    @time_from = options.fetch(:time_from, nil)
    @time_to = options.fetch(:time_to, DateTime.now) || DateTime.now
    @time_range = @time_from ? (@time_from..@time_to) : nil
    @sort_by = options.fetch(:sort_by, 'timestamp_desc') || 'timestamp_desc'
    @page = options.fetch(:page, 1)
    @per = options.fetch(:per, 25)
    @change_type = options.fetch(:change_type, nil)
  end

  def all_records
    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(build_where_conditions)
    commission_histories = apply_change_type_filter(commission_histories)
    apply_pagination(sorted(commission_histories))
  end

  def by_query(query = nil)
    validators_ids = matching_validators(query).pluck(:id)

    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(build_where_conditions(validator_id: validators_ids))
    commission_histories = apply_change_type_filter(commission_histories)                                        
    apply_pagination(sorted(commission_histories))
  end

  def total_count(query = nil)
    if query
      unpaginated_records_with_query(query).size
    else
      unpaginated_records.size
    end
  end

  def unpaginated_records
    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(build_where_conditions)
    apply_change_type_filter(commission_histories)
  end

  def unpaginated_records_with_query(query)
    validators_ids = matching_validators(query).pluck(:id)
    
    commission_histories = CommissionHistory.joins(:validator)
                                            .select(query_fields)
                                            .where(build_where_conditions(validator_id: validators_ids))
    apply_change_type_filter(commission_histories)
  end

  def exists_for_validator?(validator_id)
    CommissionHistory.where(build_where_conditions(validator_id: validator_id)).exists?
  end

  private

  def build_where_conditions(additional_conditions = {})
    conditions = { network: @network }
    conditions[:created_at] = @time_range if @time_range
    conditions.merge(additional_conditions)
  end

  def apply_change_type_filter(relation)
    return relation unless @change_type
    
    case @change_type
    when 'increase'
      relation.where('commission_after > commission_before')
    when 'decrease'
      relation.where('commission_after < commission_before')
    else
      relation
    end
  end

  def apply_pagination(commission_histories)
    commission_histories.page(@page).per(@per)
  end

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
