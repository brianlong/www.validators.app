# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_mainnet_slots
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  leader      :string(191)
#  slot_number :bigint
#  status      :integer          default("initialized")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_blockchain_mainnet_slots_on_epoch_and_leader  (epoch,leader)
#
class Blockchain::MainnetSlot < Blockchain::Slot
    enum status: { initialized: 0, has_block: 1, no_block: 2, request_error: 3 }
end
