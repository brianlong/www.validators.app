module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        stake_accounts_query = StakeAccountQuery.new(
          network: index_params[:network],
          sort_by: index_params[:sort_by],
          filter_account: index_params[:filter_account],
          filter_staker: index_params[:filter_staker],
          filter_withdrawer: index_params[:filter_withdrawer],
          filter_validator: index_params[:filter_validator]
        )

        stake_accounts = stake_accounts_query.all_records

        @stake_pools = StakePool.where(network: index_params[:network])
        @total_count = stake_accounts.size
        @total_stake = stake_accounts.map(&:delegated_stake).compact.sum
        @stake_accounts = stake_accounts.page(index_params[:page])
        if index_params[:with_batch]
          @batch = Batch.last_scored(index_params[:network]) 
        end
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
          :filter_validator,
          :with_batch
        ) 
      end
    end
  end
end
