# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @per = 25
    validators = Validator.where(network: index_params[:network])
                          .scorable
                          .preload(:validator_score_v1)
                          .index_order(validate_order)

    unless index_params[:q].blank?
      validators = ValidatorSearchQuery.new(validators).search(index_params[:q])
    end

    @validators = validators.page(index_params[:page]).per(@per)

    @batch = Batch.last_scored_v2(index_params[:network])

    if @batch
      @this_epoch = EpochHistory.find_by(
        network: index_params[:network],
        batch_uuid: @batch.uuid
      )

      validator_history_stats = Stats::ValidatorHistory.new(index_params[:network], @batch.uuid)
      at_33_stake_validator = validator_history_stats.at_33_stake&.validator
      @at_33_stake_index = (validators.index(at_33_stake_validator)&.+ 1).to_i
    end

    # flash[:error] = 'Due to an issue with our RPC server pool, the Skipped Slot % data may be inaccurate. I am aware of the problem and working on a solution. Thanks! -- Brian Long'
  end

  # GET /validators-v2
  # GET /validators-v2.json
  def index_v2
    @per = 25
    validators = Validator.where(network: index_params[:network])
                          .scorable
                          .preload(:validator_score_v1, :validator_score_v2)
                          .index_order_v2(validate_order)

    unless index_params[:q].blank?
      validators = ValidatorSearchQuery.new(validators).search(index_params[:q])
    end

    @validators = validators.page(index_params[:page]).per(@per)

    @batch = Batch.last_scored_v2(index_params[:network])

    if @batch
      @this_epoch = EpochHistory.find_by(
        network: index_params[:network],
        batch_uuid: @batch.uuid
      )

      validator_history_stats = Stats::ValidatorHistory.new(index_params[:network], @batch.uuid)
      at_33_stake_validator = validator_history_stats.at_33_stake&.validator
      @at_33_stake_index = (validators.index(at_33_stake_validator)&.+ 1).to_i
    end

    # flash[:error] = 'Due to an issue with our RPC server pool, the Skipped Slot % data may be inaccurate. I am aware of the problem and working on a solution. Thanks! -- Brian Long'
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    # Sometimes @validator is nil
    @ping_times = [] # set_ping_times

    @data = {}

    @history_limit = 240
    @block_histories = @validator.validator_block_histories.order('id desc').limit(25)
    @block_history_stats = ValidatorBlockHistoryStat.where(
      network: params[:network],
      batch_uuid: @block_histories.pluck(:batch_uuid)
    ).to_a

    i = 0

    @val_history = @validator.validator_history_last
    @val_histories = ValidatorHistory.where(
      network: params[:network],
      account: @validator.account
    ).order(created_at: :asc).last(@history_limit)

    # Grab the distances to show on the chart
    @root_blocks = @val_histories.map(&:root_distance).compact

    # Grab the distances to show on the chart
    @vote_blocks = @val_histories.map(&:vote_distance).compact

    @commission_histories = CommissionHistoryQuery.new(
      network: params[:network]
    ).exists_for_validator?(@validator.id)

    @validator.validator_block_histories
              .includes(:batch)
              .order('id desc')
              .limit(@history_limit)
              .reverse
              .each do |vbh|

      i += 1

      # We want to skip if there is no batch yet for the vbh.
      skipped_slot_all_average = vbh.batch&.skipped_slot_all_average
      next unless skipped_slot_all_average

      @data[i] = {
        skipped_slot_percent: vbh.skipped_slot_percent.to_f * 100.0,
        skipped_slot_percent_moving_average: vbh.skipped_slot_percent_moving_average.to_f * 100.0,
        cluster_skipped_slot_percent_moving_average: skipped_slot_all_average * 100
      }
    end
    # flash[:error] = 'Due to a problem with our RPC server pool, the Skipped Slot % data is inaccurate. I am aware of the problem and working on a better solution. Thanks, Brian Long'
  end

  private

  def index_params
    params.permit(:network, :order, :page, :q)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_validator
    @validator = Validator.where(
      network: params[:network],
      account: params[:account]
    ).first or redirect_to(root_url(network: params[:network]))
  end

  def set_ping_times
    # TODO replace by new ping-thing feature
    @ping_times = if @validator.nil?
                    []
                  else
                    PingTime.where(
                      network: params[:network],
                      to_account: @validator.account
                    ).order("created_at desc").limit(30)
                  end
  end

  def validate_order
    valid_orders = %w[score name stake]
    return 'score' unless params[:order].in? valid_orders

    params[:order]
  end
end
