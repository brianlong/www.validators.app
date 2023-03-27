module Api
  module V1
    class StakePoolsController < BaseController
      def index
        @stake_pools = StakePool.where(network: params[:network]).includes(:stake_accounts)
        respond_to do |format|
          format.json
          format.csv do
            send_data convert_to_csv(index_csv_headers, index_csv_row_data),
            filename: "stake-pools-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def index_csv_row_data
        @stake_pools.as_json(methods: [:validators_count, :total_stake, :average_stake])
      end

      def index_csv_headers
        StakePool::FIELDS_FOR_API.map(&:to_s)
      end

      def index_params
        params.permit(:network)
      end
    end
  end
end
