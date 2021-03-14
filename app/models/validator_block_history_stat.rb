# == Schema Information
#
# Table name: validator_block_history_stats
#
#  id                                  :bigint           not null, primary key
#  batch_uuid                          :string(255)
#  end_slot                            :bigint           unsigned
#  epoch                               :integer          unsigned
#  network                             :string(255)
#  skipped_slot_percent_moving_average :decimal(10, 4)
#  start_slot                          :bigint           unsigned
#  total_blocks_produced               :integer          unsigned
#  total_slots                         :integer          unsigned
#  total_slots_skipped                 :integer          unsigned
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_validator_block_history_stats_on_network_and_batch_uuid  (network,batch_uuid)
#

class ValidatorBlockHistoryStat < ApplicationRecord
  scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }

  # TODO add test
  after_create :set_skipped_slot_percent_moving_average

  private

  def set_skipped_slot_percent_moving_average
    self.skipped_slot_percent_moving_average = validator.validator_block_histories.last_24_hours.average(:skipped_slot_percent)
  end
end
