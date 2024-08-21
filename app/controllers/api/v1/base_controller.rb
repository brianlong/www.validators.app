# frozen_string_literal: true

module Api
  module V1
    # This is the base controller for the V1 API. It handles token
    # authentication.
    class BaseController < ActionController::API
      helper ApplicationHelper
      include ActionController::MimeResponds
      include CsvHelper
      # Special error classes:
      class ValidatorNotFound < StandardError; end

      before_action :validate_api_token

      def validate_api_token
        return true \
          if request.headers['Authorization'] && request.headers['Authorization'] == Rails.application.credentials.api_authorization

        allowed_domains = Rails.application.credentials.cors_domain_whitelist
        unless allowed_domains&.include? request.headers['origin'] # Rails.application.credentials.cors_domain_whitelist
          return unauthenticated! \
            if User.where(api_token: request.headers['Token']).first.nil?
        end

        true
      rescue ActiveRecord::ConnectionNotEstablished => e
        Appsignal.send_error(e)
        render json: { 'error' => 'Database connection error. Please try again in a few minutes.' }, status: 500
      end

      # Return a 401 if the user is not authenticated.
      def unauthenticated!
        response.headers['WWW-Authenticate'] = 'Token realm=Application'
        render json: { 'error' => 'Unauthorized' }, status: 401
      end
    end
  end
end
