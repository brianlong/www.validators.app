# frozen_string_literal: true

class ValidatorCheckActiveWorker
  include Sidekiq::Worker

  # If stake lower of eqal this value validator becomes inactive
  STAKE_EXCLUDE_HEIGHT = 0 # lamports

  # if delinquent for this period of time validator becomes inactive
  DELINQUENT_TIME = 24.hours

  def perform
    # Check for activity only validators that are active now
    Validator.scorable.each do |validator|
      if ValidatorHistory.where(account: validator.account).count > 10
        unless acceptable_stake?(validator) && not_delinquent?(validator)
          validator.update(is_active: false)
        end
      elsif validator.created_at < DateTime.now - DELINQUENT_TIME
        validator.update(is_rpc: true)
      end
    end
  end

  private

  def not_delinquent?(validator)
    nondelinquent_history = ValidatorHistory.where(
                                              account: validator.account,
                                              delinquent: false
                                            )
                                            .where(
                                              'created_at > ?',
                                              DateTime.now - DELINQUENT_TIME
                                            )

    nondelinquent_history.exists?
  end

  def acceptable_stake?(validator)
    with_acceptable_stake = ValidatorHistory.where(account: validator.account)
                                            .where(
                                              'created_at > ? AND active_stake > ?',
                                              DateTime.now - DELINQUENT_TIME,
                                              STAKE_EXCLUDE_HEIGHT
                                            )

    with_acceptable_stake.exists?
  end
end
