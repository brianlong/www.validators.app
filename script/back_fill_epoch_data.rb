# frozen_string_literal: true

%w[mainnet testnet].each do |network|
  epochs = EpochHistory.where(network: network)
                       .where('created_at >= ?', Date.today.beginning_of_year)
                       .pluck(:epoch).uniq

  epochs.each do |epoch|
    first_in_history = EpochHistory.where(epoch: epoch, network: network)
                                   .order(created_at: :desc)
                                   .last

    EpochWallClock.find_or_create_by(epoch: epoch, network: network) do |e|
      e.network = network
      e.starting_slot = first_in_history.current_slot
      e.slots_in_epoch = first_in_history.slots_in_epoch
      e.ending_slot = first_in_history.current_slot - first_in_history.slots_in_epoch
      e.created_at = first_in_history.created_at
      puts 'created new EWC'
    end

    puts first_in_history.inspect
  end
end
