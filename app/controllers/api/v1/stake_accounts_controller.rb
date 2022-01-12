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

        stake_accounts = stake_accounts_query.all_records.where.not(validator_id: nil)

        page = index_params[:page].to_i <= 0 ? 1 : index_params[:page].to_i
        @stake_pools = StakePool.where(network: index_params[:network])
        @total_stake = stake_accounts&.map(&:delegated_stake).compact.sum
        stake_accounts = stake_accounts.group_by(&:delegated_vote_account_address)
        @total_count = stake_accounts.keys.size
        sa_keys = stake_accounts.keys[((page - 1) * 10)...((page - 1) * 10 + 10)]
        @stake_accounts = sa_keys&.map {|k| {stake_accounts[k][0].validator_account => stake_accounts[k]}}

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
