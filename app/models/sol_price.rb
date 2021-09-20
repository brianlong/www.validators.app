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
#  epoch_testnet          :integer
#  exchange               :integer
#  high                   :decimal(40, 20)
#  low                    :decimal(40, 20)
#  open                   :decimal(40, 20)
#  volume                 :decimal(40, 20)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class SolPrice < ApplicationRecord
  enum exchange: { coin_gecko: 0, ftx: 1 }, _prefix: true
  enum currency: { usd: 0 }, _prefix: true
end
