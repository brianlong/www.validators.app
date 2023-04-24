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
    rewards - rewards * (manager_fee / 100.0)
  end

  # returns ROD for a single account or nil
  def calculate_apy(credits_diff, rewards, num_of_epochs, active_stake = nil)
    active_stake ||= rewards[:postBalance]
    credits_diff_percent = credits_diff / (active_stake - rewards[:amount]).to_f

    apy = (((1 + credits_diff_percent) ** num_of_epochs) - 1) * 100
    apy < 100 && apy > 0 ? apy.round(6) : nil
  end

  def number_of_epochs(network)
    stats = ClusterStat.find_or_create_by(network: network)
    epoch_duration = stats.epoch_duration ||
      ClusterStats::UpdateEpochDurationService.new(network).call.epoch_duration

    1.year.to_i / epoch_duration
  end
end
