json.stake_pools do
  json.array! @stake_pools, *StakePool::API_FIELDS
end
