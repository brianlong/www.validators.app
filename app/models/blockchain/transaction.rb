# frozen_string_literal: true

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
