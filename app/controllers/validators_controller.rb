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
      query: validators_params[:q],
      admin_warning: validators_params[:admin_warning],
      jito: validators_params[:jito] == "true"
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
    params.permit(:watchlist, :network, :q, :page, :order, :admin_warning, :jito)
  end
end
