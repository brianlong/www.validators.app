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

  after_create :set_skipped_slot_percent_moving_average

  def self.average_skipped_slot_percent_for(network, batch_uuid)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).average(:skipped_slot_percent_moving_average)
  end

  def self.median_skipped_slot_percent_for(network, batch_uuid)
    where(
      network: network,
      batch_uuid: batch_uuid
    ).median(:skipped_slot_percent_moving_average)
  end

  # returns other ValidatorBlockHistory records created within the last 24 hours of `self`
  def previous_24_hours
    self.class.where(validator: validator, network: network, created_at: 24.hours.ago..created_at)
  end

  private

  def set_skipped_slot_percent_moving_average
    self.skipped_slot_percent_moving_average = previous_24_hours.average(:skipped_slot_percent)
    save
  end
end
