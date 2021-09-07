# == Schema Information
#
# Table name: sol_prices
#
#  id                     :bigint           not null, primary key
#  close                  :decimal(20, 10)
#  currency               :integer
#  datetime_from_exchange :datetime
#  epoch_mainnet          :integer
#  epoch_testnet          :integer
#  exchange               :integer
#  high                   :decimal(20, 10)
#  low                    :decimal(20, 10)
#  open                   :decimal(20, 10)
#  volume                 :decimal(20, 10)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class SolPrice < ApplicationRecord
  enum exchange: { coingecko: 0, ftx: 1 }, _prefix: true
  enum currency: { usd: 0 }, _prefix: true
end
