# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @validators = Validator.where(network: params[:network])
                           .joins(:validator_score_v1)
                           .order('validator_score_v1s.active_stake desc')
                           .all
    # .includes(:validator_score_v1)

    # @total_active_stake = @validators.map { |v| v.active_stake }.sum
    @total_active_stake = Validator.where(network: params[:network])
                                   .joins(:validator_score_v1)
                                   .sum(:active_stake)

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.where(network: params[:network]).last
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
        @batch.uuid
      )
    @skipped_slot_median = \
      ValidatorBlockHistory.median_skipped_slot_percent_for(
        params[:network],
        @batch.uuid
      )
    @skipped_after_average = \
      ValidatorBlockHistory.average_skipped_slots_after_percent_for(
        params[:network],
        @batch.uuid
      )
    @skipped_after_median = \
      ValidatorBlockHistory.median_skipped_slots_after_percent_for(
        params[:network],
        @batch.uuid
      )
    ping_batch = PingTime.where(network: params[:network])&.last&.batch_uuid
    ping_time_stat = PingTimeStat.where(batch_uuid: ping_batch)&.last
    @ping_time_avg = ping_time_stat&.overall_average_time

    # I needed to hack this because we are occassionally receiving errors when
    # building the FeedZone and the payload = []. I am grabbing some of the most
    # recent records for the network and returning the last good record.
    # FeedZone.where(
    #   ['network = ?', params[:network]]
    # ).order('batch_created_at desc').limit(10).each do |fz|
    #   next if fz.payload.nil?
    #   next if fz.payload_version.nil?
    #   next if fz.payload == []
    #
    #   @feed_zone = fz
    #   return
    # end
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    @ping_times = PingTime.where(
      network: params[:network],
      to_account: @validator.account
    ).order('created_at desc').limit(30)

    @data = {}

    i = 0
    @validator.validator_block_histories
              .order('id desc').limit(288).reverse.each do |vbh|
      i += 1
      batch_stats = ValidatorBlockHistoryStat.where(
        network: params[:network],
        batch_uuid: vbh.batch_uuid
      ).first

      @data[i] = {
        skipped_slot_percent: vbh.skipped_slot_percent.to_f * 100.0,
        skipped_slots_after_percent: vbh.skipped_slots_after_percent.to_f * 100.0,
        cluster_skipped_slot_percent: (
              batch_stats.total_slots_skipped / batch_stats.total_slots.to_f
            ) * 100.0
      }

      @vote_account_history = \
        if @validator.vote_accounts.last
          @validator.vote_accounts.last.vote_account_histories.last
        else
          VoteAccountHistory.new
        end
    end
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
