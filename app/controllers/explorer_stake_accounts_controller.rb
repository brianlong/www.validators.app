# frozen_string_literal: true

class ExplorerStakeAccountsController < ApplicationController
  include StakeAccountsControllerHelper

  AUDITS_FILTERS = %w[active_stake account_balance credits_observed deactivating_stake delegated_stake rent_exempt_reserve].freeze
  TOP_LIMIT_COUNT = 20

  def index
    if index_params[:staker].present? || \
       index_params[:withdrawer].present? || \
       index_params[:vote_account].present? || \
       index_params[:stake_pubkey].present?
      @explorer_stake_accounts, @stake_accounts = get_explorer_stake_accounts(params: index_params)
    else
      @explorer_stake_accounts, @stake_accounts = get_explorer_stake_accounts(
        params: index_params, limit_count: TOP_LIMIT_COUNT
      )
    end

    @explorer_stake_accounts = @explorer_stake_accounts[:explorer_stake_accounts]
    @stake_histories = ExplorerStakeAccountHistoryStat.where(network: index_params[:network])
                                                      .order(epoch: :asc)
                                                      .limit(40)
    @data_for_chart = {
      average_active_stake: @stake_histories.map { |st| helpers.lamports_to_sol(st.average_active_stake.to_i).round(2) },
      active_stake_vector: @stake_histories.map { |st| helpers.lamports_to_sol(st.active_stake.to_i).round(2) },
      epochs: @stake_histories.pluck(:epoch)
    }
  end

  def show
    @explorer_stake_account = ExplorerStakeAccount.find_by(
      stake_pubkey: params[:stake_pubkey],
      network: params[:network]
    )
    @stake_account = StakeAccount.find_by(stake_pubkey: params[:stake_pubkey])
    @vote_account = VoteAccount.find_by(
      account: @explorer_stake_account.delegated_vote_account_address,
      network:params[:network]
    )
    @audits = @explorer_stake_account.audits.order(created_at: :desc).reject do |audit|
      audit.audited_changes.slice(*AUDITS_FILTERS).compact.empty?
    end
  end

  private

  def index_params
    params.permit(:staker, :withdrawer, :vote_account, :stake_pubkey, :network, :per, :page)
  end
end
