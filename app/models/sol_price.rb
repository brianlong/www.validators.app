# == Schema Information
#
# Table name: sol_prices
#
#  id                     :bigint           not null, primary key
#  average_price          :decimal(40, 20)
#  close                  :decimal(40, 20)
#  currency               :integer
#  datetime_from_exchange :datetime
#  epoch_mainnet          :integer
#  epoch_pythnet          :integer
#  epoch_testnet          :integer
#  exchange               :integer
#  high                   :decimal(40, 20)
#  low                    :decimal(40, 20)
#  open                   :decimal(40, 20)
#  volume                 :decimal(40, 20)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_sol_prices_on_datetime_from_exchange_and_exchange  (datetime_from_exchange,exchange)
#
class SolPrice < ApplicationRecord
  EXCHANGES = ['coin_gecko', 'ftx']
  CURRENCIES = ['usd']
  
  enum exchange: EXCHANGES.to_h { |el| [el, EXCHANGES.find_index(el)] }, _prefix: true
  enum currency: CURRENCIES.to_h { |el| [el, CURRENCIES.find_index(el)] }, _prefix: true
end
