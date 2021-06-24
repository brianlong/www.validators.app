# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    validators = Validator.where(network: params[:network])
                          .joins(:validator_score_v1)
                          .index_order(validate_order)

    @validators_count = validators.size
    @validators = validators.page(params[:page])

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

      validator_history = ValidatorHistoryQuery.new(params[:network], @batch.uuid)
      @total_active_stake = validator_history.total_active_stake

      at_33_stake_validator = validator_history.at_33_stake&.validator
      @at_33_stake_index = (validators.index(at_33_stake_validator)&.+ 1).to_i
    end

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

    i = 0
    if @validator.nil?
      render file: "#{Rails.root}/public/404.html" , status: 404
    else
      @validator.validator_block_histories
                .order('id desc')
                .limit(@history_limit)
                .reverse
                .each do |vbh|

        i += 1
        batch_stats = ValidatorBlockHistoryStat.find_by(
          network: params[:network],
          batch_uuid: vbh.batch_uuid
        )

        @data[i] = {
          skipped_slot_percent: vbh.skipped_slot_percent.to_f * 100.0,
          skipped_slot_percent_moving_average: vbh.skipped_slot_percent_moving_average.to_f * 100.0,
          cluster_skipped_slot_percent_moving_average: batch_stats.skipped_slot_percent_moving_average.to_f * 100.0
        }
      end
    end
    # flash[:error] = 'Due to a problem with our RPC server pool, the Skipped Slot % data is inaccurate. I am aware of the problem and working on a better solution. Thanks, Brian Long'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_validator
    @validator = Validator.where(
      network: params[:network],
      account: params[:account]
    ).first
  end

  def validate_order
    valid_orders = %w[score name]
    return 'score' unless params[:order].in? valid_orders

    params[:order]
  end
end
