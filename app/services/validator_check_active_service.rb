class ValidatorCheckActiveService

  def initialize
    # If stake lower of eqal this value validator becomes inactive
    @stake_exclude_height = 0

    # if delinquent for this period of time validator becomes inactive
    @delinquent_time = 12.hours
  end

  def update_validator_activity
    Validator.includes(:vote_accounts, :validator_score_v1).find_each do |validator|
      # Skip if validator has no history that is older than DELINQUENT_TIME
      next if too_young?(validator)

      # mark validator as destroyed if it has no recent history
      if validator_histories_for_validator(validator).empty?
        validator.assign_attributes(is_active: false, is_destroyed: true)
      else
        validator.assign_attributes(is_destroyed: false)
        assign_validator_flags(validator)
      end

      validator.save if validator.changed?
    end
  end

  private

  # returns true if validator has no history from previous epoch
  def too_young?(validator)
    !validator.validator_histories
              .where("created_at < ?", @delinquent_time.ago)
              .exists?
  end

  def validator_histories_for_validator(validator)
    ValidatorHistory.where(account: validator.account)
                    .where("created_at > ?", @delinquent_time.ago)
                    .order(created_at: :desc).to_a
  end

  def should_be_active?(validator)
    return true if acceptable_stake?(validator) && !long_time_delinquent?(validator)
    false
  end

  def should_be_rpc?(validator)
    !validator.vote_accounts.exists?
  end

  def assign_validator_flags(validator)
    validator.assign_attributes(
      is_active: should_be_active?(validator),
      is_rpc: should_be_rpc?(validator)
    )
  end

  def long_time_delinquent?(validator)
    return false if !validator.delinquent?

    validator_histories_for_validator(validator).select { |history| !history.delinquent? }.empty?
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
