json.extract! stake_account,
  :id,
  :activation_epoch,
  :active_stake,
  :delegated_vote_account_address,
  :stake_pubkey,
  :staker,
  :withdrawer,
  :stake_pool_id,
  :network,
  :batch_uuid,
  :pool_name,
  :validator_name,
  :validator_account

json.delegated_stake lamports_as_formatted_sol(stake_account.delegated_stake)
