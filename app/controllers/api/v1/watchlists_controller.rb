# frozen_string_literal: true

module Api
  module V1
    class WatchlistsController < ApiController
      before_action: :set_validator

      def update_watchlist

        if @validator && current_user
          if current_user.watched_validators.include? @validator
            current_user.user_watchlist_elements.find_by(validator: @validator).delete
            resp, status = { status: "removed" }, :ok
          else
            current_user.user_watchlist_elements.create(validator: @validator, network: watchlist_params[:network])
            resp, status = { status: "created" }, :created
          end
        else
          resp, status = { status: "data not saved" }, :unprocessable_entity
        end

        render json: resp.to_json, status: status
      end

      private

      def watchlist_params
        params.permit(:account, :network)
      end

      def set_validator
        @validator = Validator.find_by(
          network: watchlist_params[:network],
          account: watchlist_params[:account]
        )
      end
    end
  end
end
