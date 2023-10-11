#frozen_string_literal: true

module Api
  module V1
    class ExplorerStakeAccountsController < BaseController
      def index
        @explorer_stake_accounts = ExplorerStakeAccountQuery.new(
          withdrawer: explorer_params[:withdrawer],
          staker: explorer_params[:staker],
          vote_account: explorer_params[:vote_account],
          stake_pubkey: explorer_params[:stake_pubkey]
        ).call(per: explorer_params[:per], page: explorer_params[:page])
        
        render json: @explorer_stake_accounts
      end

      private

      def explorer_params
        params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
      end
    end
  end
end
