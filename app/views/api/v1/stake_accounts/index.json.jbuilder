json.stake_accounts @stake_accounts
json.total_count @total_count
json.total_stake @total_stake
json.current_epoch @current_epoch

if @batch
  json.batch @batch
end
