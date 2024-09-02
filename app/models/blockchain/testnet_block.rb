# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_testnet_blocks
#
#  id          :bigint           not null, primary key
#  block_time  :bigint
#  blockhash   :string(191)
#  epoch       :integer
#  height      :integer
#  parent_slot :bigint
#  slot_number :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_blockchain_testnet_blocks_on_slot_number  (slot_number)
#
class Blockchain::TestnetBlock < Blockchain::Block
    has_many :transactions, class_name: "Blockchain::TestnetTransaction", foreign_key: "block_id"
end
