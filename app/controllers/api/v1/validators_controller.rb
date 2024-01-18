# frozen_string_literal: true

module Api
  module V1
    class ValidatorsController < BaseController
      include ValidatorsHelper
      include ValidatorsControllerHelper
      include IpGeoCountryHelper

      before_action :set_skipped_slots_report
      before_action :set_validator_and_score, only: %i[show show_ledger]
      before_action :set_session_seed, only: %i[index]

      def index
        @validators = ValidatorQuery.new(api: true).call(
          network: index_params[:network],
          sort_order: index_params[:order],
          page: index_params[:page],
          limit: index_params[:limit],
          random_seed_val: session[:random_seed_val],
          query_params: {
            query: index_params[:q],
            active_only: index_params[:active_only].nil? ? true : index_params[:active_only]
          }
        )

        json_result = @validators.map { |val| create_json_result(val) }

        respond_to do |format|
          format.json do
            render json: JSON.dump(json_result), status: :ok
          end
          format.csv do
            send_data convert_to_csv(index_csv_headers(false), json_result.as_json),
                      filename: "validator-list-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => "server error" }, status: 500
      end

      def show
        if params[:internal]
          time_from = Time.now - 24.hours
          time_to = Time.now

          @skipped_slots = {}
          @skipped_after = {}

          @history_limit = 200
          @block_histories = @validator.validator_block_histories
                                      .where("created_at BETWEEN ? AND ?", time_from, time_to)
                                      .order(id: :desc)
                                      .limit(25)

          @block_history_stats = ValidatorBlockHistoryStat.where(
            network: params[:network],
            batch_uuid: @block_histories.pluck(:batch_uuid)
          ).to_a

          i = 0

          @val_history = @validator.validator_history_last
          @val_histories = ValidatorHistory.validator_histories_from_period(
            account: @validator.account,
            network: params[:network],
            from: time_from,
            to: time_to,
            limit: @history_limit
          )

          # Grab the root distances to show on the chart
          @root_blocks = @val_histories.map do |val_history|
            next unless val_history.root_distance
            {
              x: val_history.created_at.strftime("%H:%M"),
              y: val_history.root_distance
            }
          end

          # Grab the vote distances to show on the chart
          @vote_blocks = @val_histories.map do |val_history|
            next unless val_history.vote_distance
            {
              x: val_history.created_at.strftime("%H:%M"),
              y: val_history.vote_distance
            }
          end

          @validator.validator_block_histories
                    .includes(:batch)
                    .where("created_at BETWEEN ? AND ?", time_from, time_to)
                    .order(id: :desc)
                    .limit(@history_limit)
                    .reverse
                    .each do |vbh|

            i += 1

            # We want to skip if there is no batch yet for the vbh.
            skipped_slot_all_average = vbh.batch&.skipped_slot_all_average

            next unless skipped_slot_all_average

            @skipped_slots[i] = {
              skipped_slot_percent: (vbh.skipped_slot_percent.to_f * 100.0).round(1),
              skipped_slot_percent_moving_average: (vbh.skipped_slot_percent_moving_average.to_f * 100.0).round(1),
              cluster_skipped_slot_percent_moving_average: (skipped_slot_all_average * 100).round(1),
              label: vbh.created_at.strftime("%H:%M")
            }

            @skipped_after[i] = {
              skipped_after_percent: (vbh.skipped_slots_after_percent.to_f * 100.0).round(1),
              skipped_after_percent_moving_average: (vbh.skipped_slot_after_percent_moving_average.to_f * 100.0).round(1),
              label: vbh.created_at.strftime("%H:%M")
            }
          end

          render json: {
            validator: @validator.to_json(methods: [
              :dch_data_center_key,
              :vote_account_active,
              :commission_histories_exist,
              :avatar_file_url
            ]),
            score: @score.to_json(methods: [:displayed_total_score]),
            root_blocks: @root_blocks,
            vote_blocks: @vote_blocks,
            skipped_after: @skipped_after.to_json,
            skipped_slots: @skipped_slots.to_json,
            block_histories: @block_histories,
            block_history_stats: @block_history_stats,
            validator_history: @val_history,
            validator_score_details: validator_score_attrs(@validator),
            geo_country: set_geo_country
          }
        else
          @validator = ValidatorQuery.new.call_single_validator(
            network: validator_params["network"],
            account: validator_params["account"]
          )

          raise ValidatorNotFound if @validator.nil?

          current_epoch = EpochHistory.last
          with_history = set_boolean_field(validator_params[:with_history])
          json_result = create_json_result(@validator, with_history)

          respond_to do |format|
            format.json do
              render json: json_result
            end
            format.csv do
              send_data convert_to_csv(index_csv_headers(with_history), json_result.as_json),
                        filename: "validator-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
            end
          end
        end
      rescue ValidatorNotFound
        render json: { "status" => "Validator Not Found" }, status: 404
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => e.message }, status: 500
      end

      def show_ledger
        render json: {
          active_stake: @validator.active_stake,
          commission: @validator.commission,
          total_score: @score&.displayed_total_score,
          vote_account: @validator.vote_account_active&.account,
          name: @validator.name,
          avatar_url: @validator.avatar_url,
          www_url: @validator.www_url
        }
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { "status" => e.message }, status: 500
      end

      private

      def validator_params
        params.permit(:network, :order, :page, :limit, :q, :account, :with_history)
      end

      def index_params
        params.permit(:network, :order, :page, :limit, :q, :active_only)
      end

      def set_skipped_slots_report
        @skipped_slots_report = Report.where(
          network: validator_params[:network],
          name: "build_skipped_slot_percent"
        ).last
      end

      def set_validator_and_score
        @validator = Validator.where(
          network: validator_params[:network],
          account: validator_params[:account]
        ).first

        raise ValidatorNotFound unless @validator

        @score = @validator.score
      rescue ValidatorNotFound
        render json: { "status" => "Validator Not Found" }, status: 404
      rescue ActionController::ParameterMissing
        render json: { "status" => "Parameter Missing" }, status: 400
      end
    end
  end
end
