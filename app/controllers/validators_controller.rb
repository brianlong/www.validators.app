# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    validators = Validator.where(network: params[:network])
                          .scorable
                          .joins(:validator_score_v1)
                          .index_order(validate_order)

    @validators_count = validators.size
    @validators = validators.page(params[:page])
    @total_active_stake = validators.total_active_stake

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.last_scored(params[:network])

    if @batch
      @this_epoch = EpochHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).first

      validator_block_history_query =
        ValidatorBlockHistoryQuery.new(params[:network], @batch.uuid)

      @skipped_slot_average =
        validator_block_history_query.scorable_average_skipped_slot_percent
      @skipped_slot_median =
        validator_block_history_query.median_skipped_slot_percent
    end

    validator_history =
      ValidatorHistoryQuery.new(params[:network], @batch.uuid)

    at_33_stake_validator = validator_history.at_33_stake&.validator
    @at_33_stake_index = (validators.index(at_33_stake_validator)&.+ 1).to_i

    # flash[:error] = 'Due to a problem with our RPC server pool, the Skipped Slot % data is inaccurate. I am aware of the problem and working on a better solution. Thanks, Brian Long'
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    # Sometimes @validator is nil
    @ping_times = []
    # @ping_times = if @validator.nil?
    #                 []
    #               else
    #                   PingTime.where(
    #                   network: params[:network],
    #                   to_account: @validator.account
    #                 ).order('created_at desc').limit(30)
    #               end

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


    @validator.validator_block_histories
              .includes(:batch)
              .order('id desc')
              .limit(@history_limit)
              .reverse
              .each do |vbh|

      i += 1

      # Sometimes there is no batch yet for the vbh.
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

  # Use callbacks to share common setup or constraints between actions.
  def set_validator
    @validator = Validator.where(
      network: params[:network],
      account: params[:account]
    ).first or not_found
  end

  def validate_order
    valid_orders = %w[score name]
    return 'score' unless params[:order].in? valid_orders

    params[:order]
  end
end
