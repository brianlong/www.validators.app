json.stake_accounts do
  json.array! @stake_accounts, partial: "api/v1/stake_accounts/stake_account_detail", as: :stake_account
end

json.stake_pools do
  json.array! @stake_pools
end

json.total_count @total_count
json.total_stake @total_stake
