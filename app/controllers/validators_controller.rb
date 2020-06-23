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
