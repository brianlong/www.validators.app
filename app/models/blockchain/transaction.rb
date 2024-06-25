# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_transactions
#
#  id            :bigint           not null, primary key
#  account_key_1 :string(191)
#  account_key_2 :string(191)
#  account_key_3 :string(191)
#  epoch         :integer
#  fee           :bigint
#  network       :string(191)
#  post_balances :text(65535)
#  pre_balances  :text(65535)
#  slot_number   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Blockchain::Transaction < ApplicationRecord
  extend Archivable
  self.abstract_class = true
  
  serialize :pre_balances, JSON
  serialize :post_balances, JSON

  class << self
    def network(network)
      raise ArgumentError, 'Invalid network' unless NETWORKS.include?(network)

      case network
      when 'mainnet'
        Blockchain::MainnetTransaction
      when 'testnet'
        Blockchain::TestnetTransaction
      when 'pythnet'
        Blockchain::PythnetTransaction
      end
    end

    def count
      self.name == 'Blockchain::Transaction' ? Blockchain::MainnetTransaction.count + Blockchain::TestnetTransaction.count + Blockchain::PythnetTransaction.count : super
    end
  end
end
