# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
include SolanaLogic

NETWORKS.each do |network|
  current_epoch = EpochWallClock.where(network: network).last

  # get 100 accounts at a time to keep the request small
  VoteAccount.includes(:validator).where(network: network).in_batches(of: 100) do |batch|
    accounts = batch.pluck(:account)

    result = solana_client_request(
      NETWORK_URLS[network],
      "get_inflation_reward",
      params: [accounts]
    )

    batch.each_with_index do |va, idx|  
      next unless result[idx] # some accounts have no inflation reward e. g. if it was inactive

      # check if commission from db matches commission from get_inflation_reward
      if va.validator.commission != result[idx]["commission"].to_f
        puts "#{va.validator.account}: #{va.validator.commission} != #{result[idx]["commission"]}"
        # find or create
        va.validator.commission_histories.find_or_create_by(
          epoch: result[idx]["epoch"],
          commission_before: result[idx]["commission"].to_f
        ) do |commission|
          commission.commission_after = va.validator.commission
          commission.epoch_completion = 0.05
          commission.batch_uuid = Batch.where("created_at > ?", 1.hour.ago).where(network: network).first
          commission.from_inflation_rewards = true
        end
          
        # find or create
        va.validator.commission_histories.where(
          epoch: result[idx]["epoch"] - 1,
          commission_after: result[idx]["commission"].to_f,
        ) do |commission|
          commission_before = va.validator.commission
          commission.epoch_completion = 99.95
          commission.batch_uuid = Batch.where("created_at < ?", 1.hour.ago).where(network: network).last
          commission.from_inflation_rewards = true
        end
  
      end
    end

    sleep(2)
  end
end
