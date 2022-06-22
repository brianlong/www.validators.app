# frozen_string_literal: true

class YouController < ApplicationController
  before_action :authenticate_user!, only: [:index, :regenerate_token]

  def index
    @user = current_user
    @batch = Batch.last_scored(index_params[:network])
    @per = 25
    @validators = ValidatorQuery.new(watchlist_user: @user.id).call(
      network: index_params[:network],
      limit: @per,
      page: index_params[:page]
    )
  end

  # POST you/regenerate_token
  def regenerate_token
    current_user.regenerate_api_token
    redirect_to user_root_url
  end

  private

  def index_params
    params.permit(:network, :page)
  end
end
