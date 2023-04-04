# == Schema Information
#
# Table name: sol_prices
#
#  id                     :bigint           not null, primary key
#  average_price          :decimal(40, 20)
#  currency               :integer
#  datetime_from_exchange :datetime
#  epoch_mainnet          :integer
#  epoch_testnet          :integer
#  exchange               :integer
#  volume                 :decimal(40, 20)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_sol_prices_on_datetime_from_exchange_and_exchange  (datetime_from_exchange,exchange)
#
class SolPrice < ApplicationRecord
  EXCHANGES = %w[coin_gecko].freeze
  CURRENCIES = %w[usd].freeze

  API_FIELDS = %i[
    id
    currency
    epoch_mainnet
    epoch_testnet
    volume
    datetime_from_exchange
    created_at
    updated_at
    average_price
  ].freeze
  
  enum exchange: EXCHANGES.to_h { |el| [el, EXCHANGES.find_index(el)] }, _prefix: true
  enum currency: CURRENCIES.to_h { |el| [el, CURRENCIES.find_index(el)] }, _prefix: true
end
