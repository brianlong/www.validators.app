# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_pythnet_block_archives
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
class Blockchain::PythnetBlockArchive < ApplicationRecord
end