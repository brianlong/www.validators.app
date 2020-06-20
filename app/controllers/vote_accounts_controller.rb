# frozen_string_literal: true

class VoteAccountsController < ApplicationController
  before_action :set_vote_account, only: %i[show]

  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_vote_account
    @vote_account = VoteAccount.find(params[:id])
  end
end
