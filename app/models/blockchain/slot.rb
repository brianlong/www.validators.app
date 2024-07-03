#frozen_string_literal: true

class Blockchain::Slot < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  class << self
    def network(network)
      raise ArgumentError, 'Invalid network' unless NETWORKS.include?(network)

      case network
      when 'mainnet'
        Blockchain::MainnetSlot
      when 'testnet'
        Blockchain::TestnetSlot
      when 'pythnet'
        Blockchain::PythnetSlot
      end
    end

    def count
      self.name == 'Blockchain::Slot' ? Blockchain::MainnetSlot.count + Blockchain::TestnetSlot.count + Blockchain::PythnetSlot.count : super
    end
  end
end
