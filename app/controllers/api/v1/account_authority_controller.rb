# frozen_string_literal: true

module Api
  module V1
    class AccountAuthorityController < BaseController
      DEFAULT_PAGE = 1
      DEFAULT_PER = 100

      def index
        per = authority_params[:per].to_i <= 0 ? DEFAULT_PER : authority_params[:per].to_i
        page = authority_params[:page].to_i <= 0 ? DEFAULT_PAGE : authority_params[:page].to_i

        begin
          @account_authority_histories = AccountAuthorityQuery.new(
            network: authority_params[:network],
            vote_account: authority_params[:vote_account],
            validator: authority_params[:validator]
          ).call
        rescue ArgumentError => e
          render json: { error: e.message }, status: :bad_request and return
        end

        @account_authority_histories = @account_authority_histories.page(page).per(per)

        respond_to do |format|
          format.json { render json: @account_authority_histories.to_json }
          format.csv do
            send_data convert_to_csv(index_csv_headers, @account_authority_histories.as_json),
                      filename: "account-authority-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def index_csv_headers
        AccountAuthorityHistory::API_FIELDS.map(&:to_s)
      end

      def authority_params
        params.permit(:network, :validator, :vote_account, :per, :page)
      end
    end
  end
end
