# frozen_string_literal: true

class UsersController < ApplicationController
  def current_user_info
    response = if current_user
                { api_token: current_user.api_token }
              else
                { error: "user not signed in" }
              end

    render json: response.to_json
  end
end
