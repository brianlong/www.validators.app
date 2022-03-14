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

        @validators = Validator.select(validator_fields, validator_score_v1_fields, data_center_fields)
                               .where(network: params[:network])
                               .includes(:vote_accounts, :validator_score_v1)
                               .joins(:validator_score_v1, :data_center)
                               .preload(:most_recent_epoch_credits_by_account)
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
        @validator = Validator.select(validator_fields, validator_score_v1_fields, data_center_fields)
                              .eager_load(:vote_accounts, :validator_score_v1)
                              .joins(:data_center)
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

      private

      def create_json_result(validator, with_history = false)
        hash = {}

        hash.merge!(validator.to_builder.attributes!)

        score = validator.score
        data_center = {
          "data_center_key" => validator.data_center_key,
          "longitude" => validator.location_longitude,
          "latitude" => validator.location_latitude,
          "autonomous_system_number" => validator.traits_autonomous_system_number
        }
        vote_account = validator.vote_accounts.last
        validator_history = validator.most_recent_epoch_credits_by_account

        hash.merge!(score.to_builder(with_history: with_history).attributes!)
        hash.merge!(data_center) unless data_center.blank?
        hash.merge!(vote_account.to_builder.attributes!) unless vote_account.blank?
        hash.merge!(validator_history.to_builder.attributes!) unless validator_history.blank?

        # Data from the skipped_slots_report
        unless @skipped_slots_report.nil?
          this_report = @skipped_slots_report.payload.select do |ssr|
            ssr['account'] == validator.account
          end

          unless this_report.first.nil?
            hash.merge!({
              'skipped_slots' => this_report.first['skipped_slots'],
              'skipped_slot_percent' => this_report.first['skipped_slot_percent'],
              'ping_time' => nil # this_report.first['ping_time']
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
          'www_url',
          'avatar_url',
          'admin_warning'
        ].map { |e| "validators.#{e}" }
      end

      def validator_score_v1_fields
        [
          'active_stake',
          'commission',
          'delinquent',
          'data_center_concentration_score',
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

      def data_center_fields
        [
          "data_center_key",
          "id",
          "location_latitude",
          "location_longitude",
          "traits_autonomous_system_number"
        ].map { |e| "data_centers.#{e}" }
      end
    end
  end
end
