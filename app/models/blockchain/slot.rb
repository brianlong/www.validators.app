#frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_slots
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  has_block   :boolean
#  leader      :string(191)
#  network     :string(191)
#  slot_number :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_blockchain_slots_on_network_and_epoch_and_leader  (network,epoch,leader)
#
class Blockchain::Slot < ApplicationRecord
end
