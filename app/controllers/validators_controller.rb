# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @validators = Validator.where(network: params[:network])
                           .order('network, account')
                           .all
    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    # I needed to hack this because we are occassionally receiving errors when
    # building the FeedZone and the payload = []. I am grabbing some of the most
    # recent records for the network and returning the last good record.
    @feed_zone = FeedZone.where(
      ["network = ? and payload != '[]'", params[:network]]
    ).order('created_at desc').limit(10).each do |fz|
      next if fz.payload.nil?
      next if fz.payload == []

      return fz
    end
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
