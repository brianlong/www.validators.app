module StakeLogic::ApyHelper
  # returns [epoch that's not finished yet, last finished epoch]
  def set_epochs(network)
    last_epoch = EpochWallClock.where(
      network: network
    ).last

    previous_epoch = EpochWallClock.where(
      network: network,
      epoch: last_epoch.epoch - 1
    ).last

    [last_epoch, previous_epoch]
  end

  # returns reward from the account minus stake pool fee
  def reward_with_fee(manager_fee, rewards)
    return rewards unless manager_fee
    rewards - rewards * (manager_fee / 100)
  end

  # returns APY for a single account or nil
  def calculate_apy(credits_diff, rewards, num_of_epochs)
    puts "#{rewards[:postBalance]} - #{rewards[:amount]} = #{(rewards[:postBalance] - rewards[:amount]).to_f}"
    credits_diff_percent = credits_diff / (rewards[:postBalance] - rewards[:amount]).to_f
    puts credits_diff_percent

    apy = (((1 + credits_diff_percent) ** num_of_epochs) - 1) * 100
    puts apy
    apy #< 100 && apy > 0 ? apy.round(6) : nil
  end
end
