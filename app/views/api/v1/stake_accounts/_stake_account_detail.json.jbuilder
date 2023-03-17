json.extract! stake_account, *StakeAccount::FIELDS_FOR_API


json.active_stake lamports_as_formatted_sol(stake_account.active_stake)
