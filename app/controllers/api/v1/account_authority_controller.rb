# frozen_string_literal: true

module Api
  module V1
    class AccountAuthorityController < BaseController
      def index
        per = authority_params[:per].to_i <= 0 ? 100 : authority_params[:per].to_i
        page = authority_params[:page].to_i <= 0 ? 1 : authority_params[:page].to_i

        @validator = Validator.where(network: authority_params[:network], account: authority_params[:validator]).first

        @account_authority_histories = AccountAuthorityHistory.where(
          network: authority_params[:network],
        )

        if @validator
          @account_authority_histories = @account_authority_histories.where(validator: @validator)
        end

        @account_authority_histories = @account_authority_histories.order(created_at: :desc)
                                                                   .page(page)
                                                                   .per(per)

        respond_to do |format|
          format.json { render json: @account_authority_histories }
          format.csv do
            send_data convert_to_csv(index_csv_headers, @account_authority_histories.as_json),
                      filename: "account-authority-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def authority_params
        params.permit(:network, :validator, :per, :page)
      end
    end
  end
end
