# frozen_string_literal: true

class ValidatorCheckActiveWorker
  include Sidekiq::Worker

  # If stake lower of eqal this value validator becomes inactive
  STAKE_EXCLUDE_HEIGHT = 0 # lamports

  # if delinquent for this period of time validator becomes inactive
  DELINQUENT_TIME = 24.hours

  def perform
    Validator.all.each do |validator|
      if validator.scorable?
        check_if_should_be_scorable(validator)
      else
        # Check validators that are currently not scorable in case they reactivate
        if not_too_young?(validator) && acceptable_stake?(validator) && not_delinquent?(validator)
          validator.update(is_active: true)

        # Check if vote account has been created for rpc_node
        elsif validator.vote_accounts.exists?
          validator.update(is_rpc: false) if validator.is_rpc
        end
      end
    end
  end

  private

  def previous_epoch(network)
    current_epoch = EpochWallClock.where(network: network).order(created_at: :desc).last
    if network == 'testnet'
      @previous_epoch_testnet ||= current_epoch.epoch - 1
    else
      @previous_epoch_mainnet ||= current_epoch.epoch - 1
    end
  end

  def not_too_young?(validator)
    validator.validator_block_histories
             .where(epoch: previous_epoch(validator.network))
             .exists?
  end

  def check_if_should_be_scorable(validator)
    if ValidatorHistory.where(account: validator.account).exists?
      unless not_too_young?(validator) && \
             acceptable_stake?(validator) && \
             not_delinquent?(validator)
        validator.update(is_active: false)
      end
    elsif validator.created_at < (DateTime.now - DELINQUENT_TIME) && \
      !validator.vote_account.exists?
      # is rpc if no vote account

      validator.update(is_rpc: true)
    end
  end

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
