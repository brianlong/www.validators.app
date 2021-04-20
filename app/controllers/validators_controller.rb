# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @sort_order = if params[:order] == 'score'
                    'validator_score_v1s.total_score desc, validator_score_v1s.active_stake desc'
                  elsif params[:order] == 'name'
                    'validators.name asc'
                  else
                    'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
                  end

    validators = Validator.where(network: params[:network])
                          .joins(:validator_score_v1)
                          .order(@sort_order)
    @validators_count = validators.count
    @validators = validators.page(params[:page])

    @total_active_stake = Validator.where(network: params[:network])
                                   .joins(:validator_score_v1)
                                   .sum(:active_stake)

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.where(
      ["network = ? AND scored_at IS NOT NULL",  params[:network]]
    ).last
    
    @global_stats = ValidatorScoreStat.last
    
    if @batch
      @this_epoch = EpochHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).first
      @skipped_slot_average = \
        ValidatorBlockHistory.average_skipped_slot_percent_for(
          params[:network],
          @batch.uuid
        )
      @skipped_slot_median = \
        ValidatorBlockHistory.median_skipped_slot_percent_for(
          params[:network],
          @batch.uuid
        )
    end

    # Calculate the best skipped vote percent.
    @credits_current_max = VoteAccountHistory.where(
      network: params[:network],
      batch_uuid: @batch.uuid
    ).maximum(:credits_current).to_i
    @slot_index_current = VoteAccountHistory.where(
      network: params[:network],
      batch_uuid: @batch.uuid
    ).maximum(:slot_index_current).to_i
    @skipped_vote_percent_best = \
      (@slot_index_current - @credits_current_max )/@slot_index_current.to_f

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
end
