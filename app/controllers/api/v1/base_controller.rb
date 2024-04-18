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
        logger ||= Logger.new("#{Rails.root}/log/headers.log")
        logger.info request.headers.to_h
        logger.info "Remote IP: " + request.remote_ip.to_s
        logger.info "Origin header: " + request.headers['origin'].to_s
        logger.info "Origin: " + request.origin.to_s
        logger.info "Host: " + request.host.to_s
        logger.info "---"

        return true if ['localhost', "https://www.validators.app", "https://stage.validators.app"].include? request.host
        return true if request.headers['Authorization'] && request.headers['Authorization'] == Rails.application.credentials.api_authorization

        allowed_domains = Rails.application.credentials.cors_domain_whitelist
        return true if allowed_domains&.include? request.headers['origin']

        return unauthenticated! unless User.find_by(api_token: request.headers['Token'])

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
