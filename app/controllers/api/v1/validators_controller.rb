module Api
  module V1
    class ValidatorsController < BaseController
      include ValidatorsControllerHelper

      before_action :set_skipped_slots_report

      def index
        @validators = ValidatorQuery.new.call(
          network: params[:network],
          sort_order: params[:order],
          page: params[:page],
          limit: params[:limit],
          query: params[:q]
        )

        json_result = @validators.map { |val| create_json_result(val) }

        render json: json_result
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => "server error" }, status: 500
      end

      def show
        @validator = Validator.select(validator_fields, validator_score_v1_fields)
                              .eager_load(:validator_score_v1)
                              .find_by(network: validator_params[:network], account: validator_params["account"])

        raise ValidatorNotFound if @validator.nil?

        current_epoch = EpochHistory.last

        render json: create_json_result(@validator, validator_params[:with_history] || false)
      rescue ValidatorNotFound
        render json: { "status" => "Validator Not Found" }, status: 404
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => e.message }, status: 500
      end

      private

      def validator_params
        params.permit(:network, :order, :page, :limit, :q, :account, :with_history)
      end

      def set_skipped_slots_report
        @skipped_slots_report = Report.where(
          network: validator_params[:network],
          name: "build_skipped_slot_percent"
        ).last
      end
    end
  end
end
