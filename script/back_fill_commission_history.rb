# frozen_string_literal: true

%[mainnet testnet].each do |network|
  Validator.scorable.where(network: network).each do |validator|
    last_history = ValidatorHistory.where(account: validator.account)
                                   .order(created_at: :desc)
                                   .first
    loop do
      ValidatorHistory.where(account: validator.account)
                      .order(created_at: :desc)
                      .first
    end

  end
end