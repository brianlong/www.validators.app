# frozen_string_literal: true

%w[mainnet testnet].each do |network|
  Validator.where(network: network).find_each do |validator|
    first_history = ValidatorHistory.where(account: validator.account)
                                   .order(created_at: :desc)
                                   .last
    next unless first_history

    loop do
      changed_history = ValidatorHistory.where(account: validator.account)
                                        .where(network: network)
                                        .where.not(commission: first_history.commission)
                                        .where('created_at > ?', first_history.created_at)
                                        .where('created_at < ?', DateTime.new(2021, 7, 9))
                                        .order(created_at: :desc)
                                        .last
      break unless changed_history

      epoch_info = EpochHistory.where('created_at <= ?', changed_history.created_at)
                               .where(network: network)
                               .order(created_at: :desc)
                               .first

      new_h = validator.commission_histories.find_or_create_by(
        commission_before: first_history.commission,
        commission_after: changed_history.commission,
        batch_uuid: changed_history.batch_uuid,
        epoch: epoch_info.epoch,
        network: network,
        epoch_completion: ((epoch_info.slot_index / epoch_info.slots_in_epoch.to_f) * 100).round(2),
        created_at: changed_history.created_at
      )

      first_history = changed_history
    end

  end
end
