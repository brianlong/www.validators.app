module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        stake_accounts_query = StakeAccountQuery.new(
          network: index_params[:network]
        )

        stake_accounts = stake_accounts_query.all_records
                                             .filter_by_account(index_params[:filter_account])
                                             .filter_by_staker(index_params[:filter_staker])
                                             .filter_by_withdrawer(index_params[:filter_withdrawer])
                                             .filter_by_validator(index_params[:filter_validator])
                                             .sorted_by(index_params[:sort_by])
                                             .payload

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
