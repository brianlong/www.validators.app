# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    # Default network is 'testnet'
    @validators = Validator.where(network: params[:network])
                           .order('network, account')
                           .all
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    @ping_times = PingTime.where(
      network: params[:network],
      to_account: @validator.account
    ).order('id desc').limit(30)

    @data = {}

    i = 0
    @validator.validator_block_histories
              .order('id desc').limit(500).reverse.each do |vbh|
      i += 1
      batch_stats = ValidatorBlockHistoryStat.where(
        batch_id: vbh.batch_id
      ).first

      @data[i] = {
        skipped_slot_percent: vbh.skipped_slot_percent.to_f * 100.0,
        skipped_slots_after_percent: vbh.skipped_slots_after_percent.to_f * 100.0,
        cluster_skipped_slot_percent: (
              batch_stats.total_slots_skipped / batch_stats.total_slots.to_f
            ) * 100.0
      }
    end

    # @block_stats = \
    #   ValidatorBlockHistoryStat.where(
    #     batch_id: @validator_block_histories.first.batch_id
    #   )
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
