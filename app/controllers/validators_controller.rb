# frozen_string_literal: true

# ValidatorsController
class ValidatorsController < ApplicationController
  before_action :set_validator, only: %i[show]

  # GET /validators
  # GET /validators.json
  def index
    # Default network is 'solana-tds'
    @network ||= 'testnet' # 'main'
    @validators = Validator.where(network: @network)
                           .order('network, account')
                           .all
  end

  # GET /validators/1
  # GET /validators/1.json
  def show
    @network ||= 'testnet' # 'main'
    @ping_times = PingTime.where(
      network: @network,
      to_account: @validator.account
    ).order('id desc').limit(30)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_validator
    @validator = Validator.find(params[:id])
  end
end
