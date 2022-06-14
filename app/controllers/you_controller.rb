# frozen_string_literal: true

class YouController < ApplicationController
  before_action :authenticate_user!, only: [:index]

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
    if current_user
      current_user.regenerate_api_token
      redirect_to user_root_url
    else
      flash[:warning] = t('you.only_users_allowed')
      redirect_to :root
    end
  end

  private

  def index_params
    params.permit(:network, :page)
  end
end
