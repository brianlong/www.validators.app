module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        stake_accounts = base_query.all_records.where.not(validator_id: nil)
        page = index_params[:page].to_i <= 0 ? 1 : index_params[:page].to_i

        @stake_accounts = get_correct_records(stake_accounts, page)
        @total_stake = stake_accounts&.map(&:delegated_stake).compact.sum
        @total_count = stake_accounts.size
        @current_epoch = EpochWallClock.where(network: index_params[:network]).last&.epoch

        if index_params[:with_batch]
          @batch = Batch.last_scored(index_params[:network])
        end
      end

      private

      def base_query
        StakeAccountQuery.new(
          network: index_params[:network],
          sort_by: index_params[:sort_by],
          filter_account: index_params[:filter_account],
          filter_staker: index_params[:filter_staker],
          filter_withdrawer: index_params[:filter_withdrawer],
          filter_validator: index_params[:filter_validator]
        )
      end

      def get_correct_records(stake_accounts, page)
        # This param is used by frontend Vue view.
        if index_params[:grouped_by] && index_params[:grouped_by] == "delegated_vote_accounts_address"
          records_for_vue_frontend(stake_accounts, page)
        else
          records_for_api(stake_accounts, page)
        end
      end

      def records_for_vue_frontend(stake_accounts, page)
        stake_accounts = stake_accounts.group_by(&:delegated_vote_account_address)

        shuffled_keys = stake_accounts.keys.shuffle(random: random_by_seed(seed: index_params[:seed].to_i))
        paginated_keys = shuffled_keys[((page - 1) * 20)...((page - 1) * 20 + 20)]

        paginated_keys&.map do |k|
          { stake_accounts[k][0].validator_account => stake_accounts[k] }
        end
      end

      def records_for_api(stake_accounts, page)
        limit = index_params[:per]
        stake_accounts.page(page).per(limit)
      end

      def random_by_seed(seed: )
        Random.new(seed || rand(1..1000))
      end

      def index_params
        params.permit(
          :filter_account,
          :filter_staker,
          :filter_validator,
          :filter_withdrawer,
          :format,
          :grouped_by,
          :network,
          :page,
          :per,
          :seed,
          :sort_by,
          :with_batch
        )
      end
    end
  end
end
