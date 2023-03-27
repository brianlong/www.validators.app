json.extract! stake_account, *StakeAccount::API_FIELDS

json.active_stake lamports_as_formatted_sol(stake_account.active_stake)
