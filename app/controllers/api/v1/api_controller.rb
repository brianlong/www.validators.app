# frozen_string_literal: true

# curl -H "Token: secret-api-token" https://localhost:3000/api/v1/validators/:network
require 'appsignal'

module Api
  module V1
    # This is the V1 API controller.
    class ApiController < BaseController
      include CollectorLogic
      include ActionController::ImplicitRender

      # POST api/v1/collector
      def collector
        render json: { 'status' => 'Method Gone' }, status: 410
      end

      # This is a simple endpoint to test API connections.
      # GET api/v1/ping => { 'answer' => 'pong' }
      def ping
        render json: { 'answer' => 'pong' }, status: 200
      end

      def ping_times
        render json: { 'status' => 'Method Gone' }, status: 410
      end

      # Show the list of validators with scores
      def validators_list
        @sort_order = case params[:order]
                      when 'score'
                        'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
                      when 'name'
                        'validators.name asc'
                      when 'stake'
                        'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
                      else
                        'RAND()'
                      end

        limit = params[:limit] || 9999
        page = params[:page]

        @validators = Validator.select(validator_fields, validator_score_v1_fields)
                               .where(network: params[:network])
                               .includes(:vote_accounts, :most_recent_epoch_credits_by_account, validator_score_v1: [:ip_for_api])
                               .joins(:validator_score_v1)
                               .order(@sort_order)
                               .page(page)
                               .per(limit)

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

      # Filter params for the Collector
      def collector_params
        params.require(:collector).permit(
          :payload_type,
          :payload_version,
          :payload
        )
      end
    end
  end
end
