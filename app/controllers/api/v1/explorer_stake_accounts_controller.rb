module Api
  module V1
    class ExplorerStakeAccountsController < BaseController
      before_action :ensure_params

      def index
        @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
          withdrawer: explorer_params[:withdrawer],
          staker: explorer_params[:staker],
          vote_account: explorer_params[:vote_account],
          stake_pubkey: explorer_params[:stake_pubkey]
        ).call(per: explorer_params[:per] || 100, page: explorer_params[:page])
        
        render json: @explorer_stake_accounts
      end

      private

      def explorer_params
        params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
      end

      def ensure_params
        render(json: {
                 status: "Parameter Missing - provide one of: staker, withdrawer, vote_account, stake_pubkey"
               }, status: 400) \
          unless explorer_params[:network].present? && (
            explorer_params[:staker].present? || 
            explorer_params[:withdrawer].present? || 
            explorer_params[:vote_account].present? || 
            explorer_params[:stake_pubkey].present?
          )
      end
    end
  end
end
