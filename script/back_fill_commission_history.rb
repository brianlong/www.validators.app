# frozen_string_literal: true

%w[mainnet testnet].each do |network|
  Validator.where(network: network).each do |validator|
    last_history = ValidatorHistory.where(account: validator.account)
                                   .order(created_at: :desc)
                                   .first
    next unless last_history
    
    loop do
      changed_history = ValidatorHistory.where(account: validator.account)
                                        .where.not(commission: last_history.commission)
                                        .where('created_at < ?', last_history.created_at)
                                        .order(created_at: :desc)
                                        .first
      break unless changed_history

      epoch_info = EpochHistory.where('created_at < ?', changed_history.created_at)
                               .where(network: network)
                               .order(created_at: :desc)
                               .first

      new_h = validator.commission_histories.find_or_create_by(
        commission_before: changed_history.commission,
        commission_after: last_history.commission,
        batch_uuid: changed_history.batch_uuid,
        epoch: epoch_info.epoch,
        epoch_completion: (epoch_info.slots_in_epoch / epoch_info.slot_index.to_f).round(2)
      )

      last_history = changed_history

      puts new_h.inspect
    end

  end
end