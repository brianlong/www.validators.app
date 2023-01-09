# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    @per = 25

    if validators_params[:watchlist] && !current_user
      flash[:warning] = "You need to create an account first."
      redirect_to new_user_registration_path and return
    end

    watchlist_user = validators_params[:watchlist] ? current_user&.id : nil

    @validators = ValidatorQuery.new(watchlist_user: watchlist_user).call(
      network: validators_params[:network],
      sort_order: validators_params[:order],
      limit: @per,
      page: validators_params[:page],
      query: validators_params[:q]
    )

    @batch = Batch.last_scored(validators_params[:network])

    if @batch
      @this_epoch = EpochHistory.where(
        network: validators_params[:network],
        batch_uuid: @batch.uuid
      ).first
    end

    if validators_params[:order] == "stake" && !validators_params[:q] && !validators_params[:watchlist]
      @at_33_stake_index = at_33_stake_index(@validators, @batch, @per)
    end

    @at_33_stake_index ||= nil
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    time_from = Time.now - 24.hours
    time_to = Time.now

    @data = {}

    @history_limit = 200
    @block_histories = @validator.validator_block_histories
                                 .where("created_at BETWEEN ? AND ?", time_from, time_to)
                                 .order(id: :desc)
                                 .limit(25)

    @block_history_stats = ValidatorBlockHistoryStat.where(
      network: params[:network],
      batch_uuid: @block_histories.pluck(:batch_uuid)
    ).to_a

    i = 0

    @val_history = @validator.validator_history_last
    @val_histories = ValidatorHistory.validator_histories_from_period(
      account: @validator.account,
      network: params[:network],
      from: time_from,
      to: time_to,
      limit: @history_limit
    )

    # Grab the root distances to show on the chart
    @root_blocks = @val_histories.map do |val_history|
      next unless val_history.root_distance
      {
        x: val_history.created_at.strftime("%H:%M"),
        y: val_history.root_distance
      }
    end

    # Grab the vote distances to show on the chart
    @vote_blocks = @val_histories.map do |val_history|
      next unless val_history.vote_distance
      {
        x: val_history.created_at.strftime("%H:%M"),
        y: val_history.vote_distance
      }
    end

    @commission_histories = CommissionHistoryQuery.new(
      network: params[:network]
    ).exists_for_validator?(@validator.id)

    @validator.validator_block_histories
              .includes(:batch)
              .where("created_at BETWEEN ? AND ?", time_from, time_to)
              .order(id: :desc)
              .limit(@history_limit)
              .reverse
              .each do |vbh|

      i += 1

      # We want to skip if there is no batch yet for the vbh.
      skipped_slot_all_average = vbh.batch&.skipped_slot_all_average
      next unless skipped_slot_all_average

      @data[i] = {
        skipped_slot_percent: (vbh.skipped_slot_percent.to_f * 100.0).round(1),
        skipped_slot_percent_moving_average: (vbh.skipped_slot_percent_moving_average.to_f * 100.0).round(1),
        cluster_skipped_slot_percent_moving_average: (skipped_slot_all_average * 100).round(1),
        label: vbh.created_at.strftime("%H:%M")
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
    ).first or redirect_to(root_url(network: params[:network]))
  end

  def at_33_stake_index(validators, batch, per_page)
    validator_history_stats = Stats::ValidatorHistory.new(validators_params[:network], batch.uuid)
    at_33_stake_validator = validator_history_stats.at_33_stake&.validator

    return nil unless validators.map(&:account).compact.include? at_33_stake_validator&.account

    first_index_of_current_page = [validators_params[:page].to_i - 1, 0].max * per_page
    first_index_of_current_page + validators.index(at_33_stake_validator).to_i + 1
  end

  def validators_params
    params.permit(:watchlist, :network, :q, :page, :order)
  end
end
