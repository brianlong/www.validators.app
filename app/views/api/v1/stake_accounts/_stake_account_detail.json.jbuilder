json.extract! stake_account,
  :id,
  :activation_epoch,
  :delegated_stake,
  :delegated_vote_account_address,
  :stake_pubkey,
  :staker,
  :withdrawer,
  :stake_pool_id,
  :network,
  :batch_uuid,
  :pool_name,
  :validator_name,
  :validator_account,
  :validator_active_stake

json.active_stake lamports_as_formatted_sol(stake_account.active_stake)
