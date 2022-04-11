# frozen_string_literal: true

class VoteAccountsController < ApplicationController
  before_action :set_vote_account, only: %i[show]

  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vote_account
    @vote_account = VoteAccount.where(
      network: params[:network],
      account: params[:account],
      validator_id: params[:validator_id]
    ).last
    render file: "#{Rails.root}/public/404.html" , status: 404 \
      if @vote_account.nil?
  end
end
