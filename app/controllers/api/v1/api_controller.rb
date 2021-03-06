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
        # Rails.logger.debug params
        # Rails.logger.debug collector_params

        @collector = Collector.new(
          collector_params.merge(
            user_id: User.where(api_token: request.headers['Token']).first.id,
            ip_address: request.remote_ip
          )
        )
        # Rails.logger.debug @collector.inspect

        if @collector.save
          # TODO: Move this to a Sidekiq worker!
          payload = { collector_id: @collector.id }
          Pipeline.new(200, payload)
                  .then(&ping_times_guard)
                  .then(&ping_times_read)
                  .then(&ping_times_calculate_stats)
                  .then(&ping_times_save)
                  .then(&log_errors)

          render json: { 'status' => 'Accepted' }, status: 202
        else
          render json: { 'status' => 'Bad Request' }, status: 400
        end
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      end

      # This is a simple endpoint to test API connections.
      # GET api/v1/ping => { 'answer' => 'pong' }
      def ping
        render json: { 'answer' => 'pong' }, status: 200
      end

      def ping_times
        limit = params[:limit] || 1000
        render json: PingTime.where(network: params[:network])
                             .order('created_at desc')
                             .limit(limit).to_json, status: 200
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
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

        @validators = Validator.where(network: params[:network])
                               .includes(:validator_score_v1)
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

        render 'api/v1/validators/index', formats: :json
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      def validators_show
        @validator = Validator.where(network: params[:network], account: params['account'])                     
                              .includes(:validator_score_v1)
                              .order('network, account').first

        raise ValidatorNotFound if @validator.nil?

        @skipped_slots_report = Report.where(
          network: params[:network],
          name: 'build_skipped_slot_percent'
        ).last

        # @score = @validator.score
        # @ip = Ip.find_by(address: @score.ip_address)
        render 'api/v1/validators/show', formats: :json
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
