module Api
  module V1
    class StakeAccountHistoriesController < BaseController
      def index
        @epoch = index_params[:epoch]&.to_i
        page = index_params[:page].to_i <= 0 ? 1 : index_params[:page].to_i
        limit = [(index_params[:per] || 1000).to_i, 9999].min
        stake_accounts = base_query.all_records.where.not(validator_id: nil)
        @stake_accounts = stake_accounts.page(page).per(limit)
        @total_count ||= stake_accounts.length

        respond_to do |format|
          format.json do
            render json: {
              stake_accounts: @stake_accounts,
              total_count: @total_count,
              epoch: @epoch
            }
          end
          format.csv do
            send_data convert_to_csv(index_csv_headers, @stake_accounts.as_json),
                      filename: "stake-account-histories-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def index_csv_headers
        (
          StakeAccount::API_FIELDS +
          StakeAccount::API_VALIDATOR_FIELDS +
          StakeAccount::API_STAKE_POOL_FIELDS
        ).map(&:to_s)
      end

      def base_query
        StakeAccountHistoryQuery.new(
          network: index_params[:network],
          epoch: @epoch,
          filter_account: index_params[:filter_account],
          filter_staker: index_params[:filter_staker],
          filter_withdrawer: index_params[:filter_withdrawer],
          filter_pool: index_params[:filter_pool]
        )
      end

      def index_params
        params.permit(
          :filter_account,
          :filter_staker,
          :filter_withdrawer,
          :filter_pool,
          :format,
          :network,
          :epoch,
          :page,
          :per
        )
      end
    end
  end
end
