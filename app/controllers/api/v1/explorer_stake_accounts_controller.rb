#frozen_string_literal: true

module Api
  module V1
    class ExplorerStakeAccountsController < BaseController
      include StakeAccountsControllerHelper
      
      before_action :ensure_params

      def index
        @explorer_stake_accounts = get_explorer_stake_accounts(params: explorer_params)[0]
        
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
