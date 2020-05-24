# frozen_string_literal: true

class YouController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    if current_user
      @user = current_user
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
end
