# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_block_histories
#
#  id                                  :bigint           not null, primary key
#  validator_id                        :bigint           not null
#  epoch                               :integer
#  leader_slots                        :integer
#  blocks_produced                     :integer
#  skipped_slots                       :integer
#  skipped_slot_percent                :decimal(10, 4)
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  batch_uuid                          :string(255)
#  skipped_slots_after                 :integer
#  skipped_slots_after_percent         :decimal(10, 4)
#  network                             :string(255)
#  skipped_slot_percent_moving_average :decimal(10, 4)
#
class ValidatorBlockHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  belongs_to :validator

  scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }

  after_create :set_last_24_hours_skipped_slot_percent_moving_average

  def self.average_skipped_slot_percent_for(network, batch_uuid)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).average(:skipped_slot_percent)
  end

  def self.median_skipped_slot_percent_for(network, batch_uuid)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).median(:skipped_slot_percent)
  end

  private

  def set_last_24_hours_skipped_slot_percent_moving_average
    self.last_24_hours_skipped_slot_percent_moving_average = validator.validator_block_histories.last_24_hours.average(:skipped_slot_percent)
  end
end
