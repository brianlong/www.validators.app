# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_block_histories
#
#  id                                  :bigint           not null, primary key
#  batch_uuid                          :string(255)
#  blocks_produced                     :integer
#  epoch                               :integer
#  leader_slots                        :integer
#  network                             :string(255)
#  skipped_slot_percent                :decimal(10, 4)
#  skipped_slot_percent_moving_average :decimal(10, 4)
#  skipped_slots                       :integer
#  skipped_slots_after                 :integer
#  skipped_slots_after_percent         :decimal(10, 4)
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  validator_id                        :bigint           not null
#
# Indexes
#
#  index_validator_block_histories_on_network_and_batch_uuid       (network,batch_uuid)
#  index_validator_block_histories_on_validator_id                 (validator_id)
#  index_validator_block_histories_on_validator_id_and_created_at  (validator_id,created_at)
#  index_validator_block_histories_on_validator_id_and_epoch       (validator_id,epoch)
#
# Foreign Keys
#
#  fk_rails_...  (validator_id => validators.id)
#
class ValidatorBlockHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  belongs_to :validator

  # TOOD: This is not a good solution! It will only work at runtime. This assumes that during creation
  # of self, there are no ValidatorBlockHistoryStat records newer than self. The  beelow scope
  # needs to get refactored, and needs to take created_at into account, to ensure we aren't
  # calculating the average on records newer than self.
  scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }

  after_create :set_skipped_slot_percent_moving_average

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

  def set_skipped_slot_percent_moving_average
    self.skipped_slot_percent_moving_average = validator.validator_block_histories.last_24_hours.average(:skipped_slot_percent)
  end
end
