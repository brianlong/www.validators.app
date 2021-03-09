# == Schema Information
#
# Table name: validator_block_history_stats
#
#  id                    :bigint           not null, primary key
#  batch_uuid            :string(255)
#  epoch                 :integer          unsigned
#  start_slot            :bigint           unsigned
#  end_slot              :bigint           unsigned
#  total_slots           :integer          unsigned
#  total_blocks_produced :integer          unsigned
#  total_slots_skipped   :integer          unsigned
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  network               :string(255)
#
class ValidatorBlockHistoryStat < ApplicationRecord
end
