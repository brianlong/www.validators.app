# frozen_string_literal: true

module Api
  module V1
    # This is the base controller for the V1 API. It handles token
    # authentication.
    class BaseController < ActionController::API
      # Special error classes:
      class ValidatorNotFound < StandardError; end

      before_action :validate_api_token

      def validate_api_token
        return unauthenticated! \
          if User.where(api_token: request.headers['Token']).first.nil?

        true
      end

      # Return a 401 if the user is not authenticated.
      def unauthenticated!
        response.headers['WWW-Authenticate'] = 'Token realm=Application'
        render json: { 'error' => 'Unauthorized' }, status: 401
      end
    end
  end
end
