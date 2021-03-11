# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_block_histories
#
#  id                          :bigint           not null, primary key
#  validator_id                :bigint           not null
#  epoch                       :integer
#  leader_slots                :integer
#  blocks_produced             :integer
#  skipped_slots               :integer
#  skipped_slot_percent        :decimal(10, 4)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  batch_uuid                  :string(255)
#  skipped_slots_after         :integer
#  skipped_slots_after_percent :decimal(10, 4)
#  network                     :string(255)
#
# ValidatorBlockHistory
class ValidatorBlockHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  belongs_to :validator

  has_many(
    :associated_block_histories,
    ->(vbh) { where(validator_id: vbh.validator_id).where.not(id: vbh.id) },
    class_name: 'ValidatorBlockHistory',
    foreign_key: :validator_id
  )

  scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }

  # where("max_post_length > ?", blog.max_post_length)
  # has_many :positive_reviews, -> { where("rating > 3.0") }, class_name: "Review"
  # scope :associate

  after_create :calc_last_24_hours_skipped_slot_percent_moving_average

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

  def calc_last_24_hours_skipped_slot_percent_moving_average
    associated_block_histories
  end
end
