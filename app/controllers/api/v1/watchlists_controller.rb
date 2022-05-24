# frozen_string_literal: true

module Api
  module V1
    class WatchlistsController < ApiController
      def add_to_watchlist
        validator = Validator.find_by(
          network: watchlist_params[:network],
          account: watchlist_params[:account]
        )
        if validator && current_user
          current_user.user_watchlist_elements.create(validator: validator, network: watchlist_params[:network])
          resp, status = { status: "ok" }, :ok
        else
          resp, status = { status: "data not saved" }, :unprocessable_entity
        end

        render json: resp.to_json, status: status
      end

      private

      def watchlist_params
        params.permit(:account, :network)
      end
    end
  end
end
