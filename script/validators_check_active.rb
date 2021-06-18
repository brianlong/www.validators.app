# frozen_string_literal: true

# If stake lower of eqal this value validator becomes inactive
@stake_exclude_height = 0 #lamports

# if delinquent for this period of time validator becomes inactive
@delinquent_time = 24.hours

def not_delinquent?(validator)
  # New Validators should not be delinquent
  return true if ValidatorHistory.where(account: validator.account).count < 10

  nondelinquent_history = ValidatorHistory.where(account: validator.account)
                                          .where(
                                            'created_at > ?',
                                            DateTime.now - @delinquent_time
                                          )
                                          .where(delinquent: false)
  nondelinquent_history.exists?
end

def acceptable_stake?(validator)
  # New validators should not be checked for stake
  return true if ValidatorHistory.where(account: validator.account).count < 10

  with_acceptable_stake = ValidatorHistory.where(account: validator.account)
                                          .where(
                                            'created_at > ?',
                                            DateTime.now - @delinquent_time
                                          )
                                          .where(
                                            'active_stake > ?',
                                            @stake_exclude_height
                                          )
  with_acceptable_stake.exists?
end

# Check only validators that are active now
Validator.scorable.each do |validator|
  unless acceptable_stake?(validator) && not_delinquent?(validator)
    validator.update(is_active: false)
  end
end