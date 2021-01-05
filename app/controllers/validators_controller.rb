# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @sort_order = if params[:order] == 'score'
                    'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
                  elsif params[:order] == 'name'
                    'validators.name asc'
                  else
                    'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
                  end

    @validators = Validator.where(network: params[:network])
                           .joins(:validator_score_v1)
                           .order(@sort_order)
                           .page(params[:page])

    @total_active_stake = Validator.where(network: params[:network])
                                   .joins(:validator_score_v1)
                                   .sum(:active_stake)

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.where(network: params[:network]).last
    # Use the previous batch for average & median stats since the most recent
    # batch might still be in process.
    @batch_previous = Batch.find(@batch.id - 1)
    if @batch
      @this_epoch = EpochHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).first
      @tower_highest_block = ValidatorHistory.highest_root_block_for(
        params[:network],
        @batch.uuid
      )
      @tower_highest_vote = ValidatorHistory.highest_last_vote_for(
        params[:network],
        @batch.uuid
      )
      @skipped_slot_average = \
        ValidatorBlockHistory.average_skipped_slot_percent_for(
          params[:network],
          @batch_previous.uuid
        )
      @skipped_slot_median = \
        ValidatorBlockHistory.median_skipped_slot_percent_for(
          params[:network],
          @batch_previous.uuid
        )
    end

    # Ping Times
    ping_batch = PingTime.where(network: params[:network])&.last&.batch_uuid
    ping_time_stat = PingTimeStat.where(batch_uuid: ping_batch)&.last
    @ping_time_avg = ping_time_stat&.overall_average_time

    flash[:error] = 'Due to a problem with our RPC server pool, the Skipped Slot % data is inaccurate. I am aware of the problem and working on a better solution. Thanks, Brian Long'

  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    @ping_times = PingTime.where(
      network: params[:network],
      to_account: @validator.account
    ).order('created_at desc').limit(30)

    @data = {}

    @history_limit = 240

    i = 0
    @validator.validator_block_histories
              .order('id desc').limit(@history_limit).reverse.each do |vbh|
      i += 1
      batch_stats = ValidatorBlockHistoryStat.where(
        network: params[:network],
        batch_uuid: vbh.batch_uuid
      ).first

      @data[i] = {
        skipped_slot_percent: vbh.skipped_slot_percent.to_f * 100.0,
        cluster_skipped_slot_percent: (
              batch_stats.total_slots_skipped / batch_stats.total_slots.to_f
            ) * 100.0
      }
    end
    
    flash[:error] = 'Due to a problem with our RPC server pool, the Skipped Slot % data is inaccurate. I am aware of the problem and working on a better solution. Thanks, Brian Long'

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
