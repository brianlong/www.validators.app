json.stake_pools do
  json.array! @stake_pools, *StakePool::FIELDS_FOR_API

end
