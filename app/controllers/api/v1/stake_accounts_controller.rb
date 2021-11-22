module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        stake_accounts_query = StakeAccountQuery.new(
          network: index_params[:network]
        )

        stake_accounts = stake_accounts_query.call(
          account: index_params[:filter_account],
          staker: index_params[:filter_staker],
          withdrawer: index_params[:filter_withdrawer],
          validator_query: index_params[:filter_validator],
          sort: index_params[:sort_by]
        )

        @total_count = stake_accounts.size
        @total_stake = stake_accounts.map(&:delegated_stake).compact.sum
        @stake_accounts = stake_accounts.page(index_params[:page])
      end

      private

      def index_params
        params.permit(
          :network,
          :per,
          :page,
          :sort_by,
          :filter_account,
          :filter_staker,
          :filter_withdrawer,
          :filter_validator
        ) 
      end
    end
  end
end
