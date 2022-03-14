module Api
  module V1
    class ValidatorsController < BaseController
      def validators_list
        @validators = ValidatorQuery.new(
          network: "mainnet",
          sort_order: "score",
          limit: 9999,
          page: 1
        ).call

        unless params[:q].blank?
          @validators = ValidatorSearchQuery.new(@validators).search(params[:q])
        end

        @skipped_slots_report = Report.where(
          network: params[:network],
          name: 'build_skipped_slot_percent'
        ).last

        json_result = @validators.map { |val| create_json_result(val) }

        render json: json_result
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      def validators_show
        @validator = Validator.select(validator_fields, validator_score_v1_fields)
                              .eager_load(:validator_score_v1)
                              .find_by(network: params[:network], account: params['account'])

        raise ValidatorNotFound if @validator.nil?

        @skipped_slots_report = Report.where(
          network: params[:network],
          name: 'build_skipped_slot_percent'
        ).last

        current_epoch = EpochHistory.last

        render json: create_json_result(@validator, params[:with_history] || false)
      rescue ValidatorNotFound
        render json: { 'status' => 'Validator Not Found' }, status: 404
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      def validator_block_history
        @validator = Validator.where(
          network: params[:network], account: params['account']
        ).order('network, account').first

        raise ValidatorNotFound if @validator.nil?

        @limit = params[:limit] || 9999

        @block_history = @validator.validator_block_histories
                                   .order('id desc')
                                   .limit(@limit)

        render 'api/v1/validators/block_history', formats: :json
      rescue ValidatorNotFound
        render json: { 'status' => 'Validator Not Found' }, status: 404
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end
    end
  end
end
