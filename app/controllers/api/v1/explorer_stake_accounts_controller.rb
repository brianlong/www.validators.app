#frozen_string_literal: true

module Api
  module V1
    class ExplorerStakeAccountsController < BaseController
      include StakeAccountsControllerHelper
      
      before_action :ensure_params

      def index
        @explorer_stake_accounts = get_explorer_stake_accounts(params: explorer_params)[0]
        
        respond_to do |format|
          format.json do
            render json: @explorer_stake_accounts
          end
          format.csv do
            @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
            send_data convert_to_csv(@explorer_stake_accounts.first.attributes.keys, @explorer_stake_accounts.as_json),
                      filename: "stake-accounts-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
        
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
