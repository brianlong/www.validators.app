# == Schema Information
#
# Table name: blockchain_blocks
#
#  id          :bigint           not null, primary key
#  block_time  :bigint
#  blockhash   :string(191)
#  height      :bigint
#  parent_slot :bigint
#  slot_number :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Blockchain::Block < ApplicationRecord
end
