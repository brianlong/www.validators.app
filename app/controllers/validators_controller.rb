# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  include ValidatorsControllerHelper

  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    search_with_results_action
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

  def validators_params
    params.permit(:watchlist, :network, :q, :page, :order, :admin_warning)
  end
end
