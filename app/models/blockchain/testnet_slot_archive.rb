# frozen_string_literal: true

# == Schema Information
#
# Table name: blockchain_testnet_slot_archives
#
#  id          :bigint           not null, primary key
#  epoch       :integer
#  leader      :string(191)
#  slot_number :bigint
#  status      :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Blockchain::TestnetSlotArchive < ApplicationRecord
    connects_to database: { writing: :blockchain, reading: :blockchain }
    # connects_to database: { writing: Rails.env.stage? ? nil : :blockchain, reading: :blockchain }
end
