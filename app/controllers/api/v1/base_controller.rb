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
        logger ||= Logger.new("#{Rails.root}/log/user_headers_logger.log")
        country = request.env["HTTP_CF_IPCOUNTRY"].to_s
        logger.info "HTTP_CF_IPCOUNTRY: " + country
        # if country == "NLD"
        #   logger.info "Remote IP: " + request.remote_ip
        # end
        logger.info "---"

        return true \
          if request.headers['Authorization'] && request.headers['Authorization'] == Rails.application.credentials.api_authorization

        allowed_domains = Rails.application.credentials.cors_domain_whitelist
        unless allowed_domains&.include? request.headers['origin'] # Rails.application.credentials.cors_domain_whitelist
          return unauthenticated! \
            if User.where(api_token: request.headers['Token']).first.nil?
        end

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
