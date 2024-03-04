# frozen_string_literal: true

module ExplorerStakeAccountsControllerHelper
  def prepare_data_for_charts(stake_histories)
    {
      active_stake: stake_histories.map { |st| helpers.lamports_to_sol(st.active_stake.to_i).round(2) },
      delegated_stake: stake_histories.map { |st| helpers.lamports_to_sol(st.delegated_stake.to_i).round(2) },
      epochs: stake_histories.pluck(:epoch),
      average_stake: stake_histories.map { |st| helpers.lamports_to_sol(st.average_active_stake.to_i).round(2) },
      deactivating_stake: stake_histories.map { |st| helpers.lamports_to_sol(st.deactivating_stake.to_i).round(2) },
      stake_accounts_count: stake_histories.pluck(:delegating_stake_accounts_count)
    }
  end
end
