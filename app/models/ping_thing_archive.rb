#frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_archives
#
#  id                          :bigint           not null, primary key
#  amount                      :bigint
#  application                 :string(191)
#  commitment_level            :integer
#  network                     :string(191)
#  pinger_region               :string(191)
#  priority_fee_micro_lamports :float(24)
#  priority_fee_percentile     :integer
#  reported_at                 :datetime
#  response_time               :integer
#  signature                   :string(191)
#  slot_landed                 :bigint
#  slot_sent                   :bigint
#  success                     :boolean
#  transaction_type            :string(191)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  user_id                     :integer
#
class PingThingArchive < ApplicationRecord
  
end
