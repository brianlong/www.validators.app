class ValidatorCheckActiveService

  def initialize
    # If stake lower of eqal this value validator becomes inactive
    @stake_exclude_height = 0

    # if delinquent for this period of time validator becomes inactive
    @delinquent_time = 24.hours
  end

  def update_validator_activity
    Validator.includes(:vote_accounts).each do |validator|
      if should_be_destroyed?(validator)
        validator.update(is_active: false, is_destroyed: true)
      elsif validator.scorable?
        update_scorable(validator)
      else
        # Check validators that are currently not scorable in case they reactivate
        if acceptable_stake?(validator) && not_delinquent?(validator)
          validator.update(is_active: true, is_destroyed: false)
        end
        
        # Check if vote account has been created for rpc_node
        if validator.vote_accounts.exists?
          validator.update(is_rpc: false) if validator.is_rpc
        end
      end
    end
  end

  private

  def should_be_destroyed?(validator)
    if !validator.validator_histories.exists? || \
      (!validator.validator_histories.where("created_at > ?", @delinquent_time.ago).exists? && \
       validator.validator_histories.where("created_at < ?", @delinquent_time.ago).exists?)
      return true
    end

    false
  end

  # number of previous by network
  def previous_epoch(network)
    @current_epoch ||= EpochWallClock.where(network: network).order(created_at: :desc).last
    case network
    when "mainnet"
      @previous_epoch_mainnet ||= @current_epoch.epoch - 1
    when "testnet"
      @previous_epoch_testnet ||= @current_epoch.epoch - 1
    when "pythnet"
      @previous_epoch_pythnet ||= @current_epoch.epoch - 1
    end
  end

  # returns true if validator has no history from previous epoch
  def too_young?(validator)
    !validator.validator_block_histories
              .where(epoch: previous_epoch(validator.network))
              .exists?
  end

  def became_inactive?(validator)
    if ValidatorHistory.where(account: validator.account).exists?
      unless acceptable_stake?(validator) && not_delinquent?(validator)
        return true
      end
    end

    false
  end

  def is_rpc?(validator)
    if validator.created_at < (DateTime.now - @delinquent_time) && \
       !validator.vote_accounts.exists?
      return true
    end

    false
  end

  def update_scorable(validator)
    if !too_young?(validator) && became_inactive?(validator)
      validator.update(is_active: false)
    end

    validator.update(is_rpc: true) if is_rpc?(validator)
  end

  # returns true if validator was not delinquent for any period of time since DELINQUENT_TIME
  def not_delinquent?(validator)
    nondelinquent_history = ValidatorHistory.where(
                                              account: validator.account,
                                              delinquent: false
                                            )
                                            .where(
                                              'created_at > ?',
                                              DateTime.now - @delinquent_time
                                            )

    nondelinquent_history.exists?
  end

  # returns true if if validator had stake gt STAKE_EXCLUDE_HEIGHT since DELINQUENT_TIME
  def acceptable_stake?(validator)
    with_acceptable_stake = ValidatorHistory.where(account: validator.account)
                                            .where(
                                              'created_at > ? AND active_stake > ?',
                                              DateTime.now - @delinquent_time,
                                              @stake_exclude_height
                                            )

    with_acceptable_stake.exists?
  end

end
