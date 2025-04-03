# frozen_string_literal: true

class Blockchain::Transaction < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  API_FIELDS = %i[
    slot_number
    fee
    account_key_1
    account_key_2
    account_key_3
    epoch
    pre_balances
    post_balances
  ].freeze

  connects_to database: { writing: :blockchain, reading: :blockchain }
  
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

  def to_builder
    Jbuilder.new do |transaction|
      transaction.(
        self,
        *API_FIELDS
      )
    end
  end
end
