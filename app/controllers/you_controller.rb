# frozen_string_literal: true

class YouController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    if current_user
      @user = current_user
      @validators = @user.watched_validators
                         .where(network: index_params[:network])
                         .preload(:validator_score_v1)
                         .joins(:validator_score_v1)
                         .order("validator_score_v1s.total_score desc, RAND()")
      if @validators.present?
        @batch = Batch.last_scored(index_params[:network])
        @per = 25
      end
    else
      flash[:warning] = t('you.only_users_allowed')
      redirect_to :root
    end
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
    params.permit(:network)
  end
end
