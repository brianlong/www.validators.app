# frozen_string_literal: true

class Blockchain::Block < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  class << self
    def network(network)
      raise ArgumentError, 'Invalid network' unless NETWORKS.include?(network)

      case network
      when 'mainnet'
        Blockchain::MainnetBlock
      when 'testnet'
        Blockchain::TestnetBlock
      when 'pythnet'
        Blockchain::PythnetBlock
      end
    end

    def count
      self.name == 'Blockchain::Block' ? Blockchain::MainnetBlock.count + Blockchain::TestnetBlock.count + Blockchain::PythnetBlock.count : super
    end
  end
end
