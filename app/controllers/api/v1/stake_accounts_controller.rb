module Api
  module V1
    class StakeAccountsController < BaseController
      def index
        @stake_accounts = StakeAccount.all
                                      .page(epoch_params[:page])
                                      .per(epoch_params[:per])
      end
    end
  end
end