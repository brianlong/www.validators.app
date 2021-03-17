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
  # TOOD: This is not a good solution! It will only work at runtime. This assumes that during creation
  # of self, there are no ValidatorBlockHistoryStat records newer than self. The  beelow scope
  # needs to get refactored, and needs to take created_at into account, to ensure we aren't
  # calculating the average on records newer than self.
  # scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }

  after_create :set_skipped_slot_percent_moving_average

  # def self.last_60_mins_skipped_slot_percent_moving_average(network)
  #   where(network: network)
  #     .last(60)
  #     .map do |vbhs|
  #       (vbhs.skipped_slot_percent_moving_average.to_f * 100.0).round(1)
  #     end
  # end

  # def previous_60_mins_skipped_slot_percent_moving_average
  #   self.class
  #     .where(network: network, created_at: 60.minutes.ago..created_at)
  #     .map do |vbhs|
  #       (vbhs.skipped_slot_percent_moving_average.to_f * 100.0).round(1)
  #     end
  # end

  def previous_24_hours
    self.class.where(network: network, created_at: 24.hours.ago..created_at)
  end

  private

  def set_skipped_slot_percent_moving_average
    skipped_slot_percents = previous_24_hours.map do |vbhs|
      vbhs.total_slots_skipped.to_f / vbhs.total_slots.to_f
    end

    average = skipped_slot_percents.sum(0.0) / skipped_slot_percents.length
    self.skipped_slot_percent_moving_average = average
    save
  end
end
