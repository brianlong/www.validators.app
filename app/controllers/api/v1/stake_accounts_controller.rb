module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        stake_accounts_query = StakeAccountQuery.new(
          network: index_params[:network],
          sort_by: index_params[:sort_by]
        )

        stake_accounts = stake_accounts_query.all_records

        total_count = stake_accounts.size

        stake_accounts = stake_accounts.page(index_params[:page])

        render json: {
          stake_accounts: stake_accounts.as_json,
          total_count: total_count
        },
        status: :ok
      end

      private

      def index_params
        params.permit :network, :per, :page, :sort_by
      end
    end
  end
end
