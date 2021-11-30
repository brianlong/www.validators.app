json.stake_accounts do
  json.array! @stake_accounts
end

json.stake_pools do
  json.array! @stake_pools
end

json.total_count @total_count
json.total_stake @total_stake
