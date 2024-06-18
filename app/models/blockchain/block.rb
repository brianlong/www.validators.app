# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_blocks
#
#  id          :bigint           not null, primary key
#  block_time  :bigint
#  blockhash   :string(191)
#  epoch       :integer
#  height      :bigint
#  network     :string(191)
#  parent_slot :bigint
#  slot_number :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_blockchain_blocks_on_network_and_slot_number  (network,slot_number)
#
class Blockchain::Block < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  class << self
    def network(network)
      raise ArgumentError, 'Invalid network' unless %w[mainnet testnet pythnet].include?(network)

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
