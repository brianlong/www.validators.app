# frozen_string_literal: true

class UsersController < ApplicationController
  def current_user_info
    if current_user
      response = {
        api_token: current_user.api_token
      }
    else
      response = {
        error: "user not signed in"
      }
    end

    render json: response.to_json
  end
end
