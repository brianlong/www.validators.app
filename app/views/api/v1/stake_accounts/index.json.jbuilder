json.stake_accounts @stake_accounts

json.stake_pools do
  json.array! @stake_pools,
    :id,
    :name,
    :network,
    :manager_fee,
    :ticker,
    :average_validators_commission,
    :average_delinquent,
    :average_apy,
    :average_skipped_slots,
    :average_uptime,
    :average_lifetime,
    :validators_count,
    :authority
end

json.total_count @total_count
json.total_stake @total_stake

if @batch
  json.batch @batch
end
