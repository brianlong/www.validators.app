# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_mainnet_slot_archives
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  leader      :string(191)
#  slot_number :bigint
#  status      :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Blockchain::MainnetSlotArchive < Blockchain::Archive
end
