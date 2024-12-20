# frozen_string_literal: true

module Api
  module V1
    class ExplorerStakeAccountsController < BaseController
      include StakeAccountsControllerHelper
      
      before_action :ensure_params

      def index
        explorer_params[:per] = [(explorer_params[:per] || 25).to_i, 999].min
        @explorer_stake_accounts = get_explorer_stake_accounts(params: explorer_params)[0]
        
        @explorer_stake_accounts = @explorer_stake_accounts.as_json(except: :id)
        respond_to do |format|
          format.json do
            render json: @explorer_stake_accounts
          end
          format.csv do
            @explorer_stake_accounts = @explorer_stake_accounts["explorer_stake_accounts"]
            send_data convert_to_csv(@explorer_stake_accounts[0].keys, @explorer_stake_accounts),
                      filename: "stake-accounts-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"
          end
        end
      end

      private

      def explorer_params
        params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
      end

      def ensure_params
        if (explorer_params[:staker].blank? && \
           explorer_params[:withdrawer].blank? && \
           explorer_params[:vote_account].blank? && \
           explorer_params[:stake_pubkey].blank?) || \
           params[:network].blank?

          render(json: {
            status: "Parameter Missing - provide one of: staker, withdrawer, vote_account, stake_pubkey"
          }, status: 400)
        end
      end
    end
  end
end
