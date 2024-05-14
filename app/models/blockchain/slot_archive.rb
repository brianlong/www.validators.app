# == Schema Information
#
# Table name: blockchain_slot_archives
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  leader      :string(191)
#  network     :string(191)
#  slot_number :bigint
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Blockchain::SlotArchive < ApplicationRecord
end
