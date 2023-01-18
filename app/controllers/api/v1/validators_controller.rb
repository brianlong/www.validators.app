# frozen_string_literal: true

module Api
  module V1
    class ValidatorsController < BaseController
      include ValidatorsControllerHelper

      before_action :set_skipped_slots_report

      def index
        @validators = ValidatorQuery.new(api: true).call(
          network: params[:network],
          sort_order: params[:order],
          page: params[:page],
          limit: params[:limit],
          query: params[:q]
        )

        json_result = @validators.map { |val| create_json_result(val) }

        # render json: json_result, status: :ok
        render json: JSON.dump(json_result), status: :ok
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

          @validator = Validator.where(
            network: params[:network],
            account: params[:account]
          ).first

          @score = @validator.score
          @data = {}

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

          @commission_histories = CommissionHistoryQuery.new(
            network: params[:network]
          ).exists_for_validator?(@validator.id)

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

            @data[i] = {
              skipped_slot_percent: (vbh.skipped_slot_percent.to_f * 100.0).round(1),
              skipped_slot_percent_moving_average: (vbh.skipped_slot_percent_moving_average.to_f * 100.0).round(1),
              cluster_skipped_slot_percent_moving_average: (skipped_slot_all_average * 100).round(1),
              label: vbh.created_at.strftime("%H:%M")
            }
          end

          render json: {
            validator: @validator.to_json(methods: [:dch_data_center_key, :vote_account_active, :commission_histories_exist]),
            score: @score.to_json(methods: [:displayed_total_score]),
            root_blocks: @root_blocks,
            vote_blocks: @vote_blocks,
            skipped_slots: @data.to_json,
            block_histories: @block_histories,
            block_history_stats: @block_history_stats,
            validator_history: @val_history
          }
        else
          @validator = ValidatorQuery.new.call_single_validator(
            network: validator_params["network"],
            account: validator_params["account"]
          )

          raise ValidatorNotFound if @validator.nil?

          current_epoch = EpochHistory.last
          with_history = set_boolean_field(validator_params[:with_history])

          render json: create_json_result(@validator, with_history)
        end
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
