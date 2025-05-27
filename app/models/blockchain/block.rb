# frozen_string_literal: true

class Blockchain::Block < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  API_FIELDS = %i[
    block_time
    blockhash
    epoch
    height
    parent_slot
    slot_number
  ].freeze

  connects_to database: { writing: :blockchain, reading: :blockchain }

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

  def to_builder
    Jbuilder.new do |block|
      block.(
        self,
        *API_FIELDS
      )
    end
  end
end
