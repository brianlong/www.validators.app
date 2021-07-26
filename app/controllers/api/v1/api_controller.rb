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

        @validators = Validator.select(validator_fields, validator_score_v1_fields)
                               .where(network: params[:network])
                               .includes(:vote_accounts, validator_score_v1: [:ip_for_api])
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

        render json: create_json_result(@validator)
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

      private

      def create_json_result(validator)
        hash = {}

        hash.merge!(validator.to_builder.attributes!)

        score = validator.score
        ip = score.ip_for_api if score
        vote_account = validator.vote_accounts.last

        hash.merge!(score.to_builder.attributes!)
        hash.merge!(ip.to_builder.attributes!) unless ip.blank?
        hash.merge!(vote_account.to_builder.attributes!) unless vote_account.blank?

        # Data from the skipped_slots_report
        unless @skipped_slots_report.nil?
          this_report = @skipped_slots_report.payload.select do |ssr|
            ssr['account'] == validator.account
          end

          unless this_report.first.nil?
            hash.merge!({
              skipped_slots: this_report.first['skipped_slots'],
              skipped_slot_percent: this_report.first['skipped_slot_percent'],
              ping_time: nil # this_report.first['ping_time']
            })
          end
        end

        hash.merge!({url: validator.api_url})
        hash
      end

      def validator_fields
        [ 
          'account',
          'created_at',
          'details',
          'id',
          'keybase_id',
          'name',
          'network', 
          'updated_at',
          'www_url'
        ].map { |e| "validators.#{e}" }
      end

      def validator_score_v1_fields 
        [
          'active_stake',
          'commission',
          'delinquent',
          'data_center_concentration_score',
          'data_center_key',
          'data_center_host',
          'published_information_score',
          'root_distance_score',
          'security_report_score',
          'skipped_slot_score',
          'software_version',
          'software_version_score',
          'stake_concentration_score',
          'total_score',
          'validator_id',
          'vote_distance_score'
        ].map { |e| "validator_score_v1s.#{e}" }
      end
    end
  end
end
