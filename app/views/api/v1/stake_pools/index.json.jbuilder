json.stake_pools do
  json.array! @stake_pools,
    :id,
    :authority,
    :average_apy,
    :average_delinquent,
    :average_lifetime,
    :average_score,
    :average_skipped_slots,
    :average_uptime,
    :average_validators_commission,
    :manager_fee,
    :name,
    :network,
    :ticker,
    :validators_count
end
