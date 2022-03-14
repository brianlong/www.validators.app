# frozen_string_literal: true

module Api
  module V1
    class ValidatorBlockHistoriesController < BaseController
      def show
        @validator = Validator.where(
          network: block_params[:network], account: block_params[:account]
        ).order("network, account").first

        raise ValidatorNotFound if @validator.nil?

        @limit = block_params[:limit] || 9999

        @block_history = @validator.validator_block_histories
                                   .order("id desc")
                                   .limit(@limit)

        render 'api/v1/validators/block_history', formats: :json
      rescue ValidatorNotFound
        render json: { "status" => "Validator Not Found" }, status: 404
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => "server error" }, status: 500
      end

      private 

      def block_params
        params.permit(:network, :account, :limit)
      end
    end
  end
end
