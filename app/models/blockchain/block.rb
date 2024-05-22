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
end
