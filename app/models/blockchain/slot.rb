#frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_slots
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  leader      :string(191)
#  network     :string(191)
#  slot_number :bigint
#  status      :integer          default("initialized")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_blockchain_slots_on_network_and_epoch_and_leader  (network,epoch,leader)
#  index_blockchain_slots_on_network_and_slot_number       (network,slot_number)
#  index_blockchain_slots_on_network_and_status_and_epoch  (network,status,epoch)
#
class Blockchain::Slot < ApplicationRecord
  extend Archivable
  self.abstract_class = true

  class << self
    def network(network)
      raise ArgumentError, 'Invalid network' unless %w[mainnet testnet pythnet].include?(network)

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
