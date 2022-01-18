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

        @total_stake = stake_accounts&.map(&:delegated_stake).compact.sum
        @total_count = stake_accounts.size

        page = index_params[:page].to_i <= 0 ? 1 : index_params[:page].to_i

        # This param is used by frontend Vue view.
        if params[:grouped_by] == "delegated_vote_accounts_address"
          stake_accounts = stake_accounts.group_by(&:delegated_vote_account_address)

          sa_keys = stake_accounts.keys[((page - 1) * 20)...((page - 1) * 20 + 20)]

          @stake_accounts = sa_keys&.map do |k|
            { stake_accounts[k][0].validator_account => stake_accounts[k] }
          end
        else
          page = params[:page]
          limit = params[:per]
          @stake_accounts = stake_accounts.page(page).per(limit)
        end

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
          :with_batch,
          :format
        )
      end
    end
  end
end
