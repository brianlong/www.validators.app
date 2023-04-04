class ValidatorCheckActiveService

  def initialize
    # If stake lower of eqal this value validator becomes inactive
    @stake_exclude_height = 0

    # if delinquent for this period of time validator becomes inactive
    @delinquent_time = 12.hours
  end

  def update_validator_activity
    Validator.find_each do |validator|
      if should_be_destroyed?(validator)
        validator.update(is_active: false, is_destroyed: true)
      elsif validator.scorable?
        update_scorable(validator)
      else
        # Check validators that are currently not scorable in case they reactivate
        if acceptable_stake?(validator) && !delinquent?(validator)
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

  def current_epoch(network)
    @current_epochs ||= {}
    return @current_epochs[network] if @current_epochs[network].present?

    @current_epochs[network] = EpochWallClock.where(network: network).order(created_at: :desc).first
  end

  # returns true if validator has no history from previous epoch
  def too_young?(validator)
    !validator.validator_histories
              .where("created_at < ?", @delinquent_time.ago)
              .exists?
  end

  def became_inactive?(validator)
    if ValidatorHistory.where(account: validator.account).exists?
      unless acceptable_stake?(validator) && !delinquent?(validator)
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

  def delinquent?(validator)
    return false if !validator.delinquent?

    !non_delinquent_history_exists?(validator)
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

  def non_delinquent_history_exists?(validator)
    ValidatorHistory.where(account: validator.account, delinquent: false)
                    .where("created_at > ?", @delinquent_time.ago)
                    .exists?
  end
end
