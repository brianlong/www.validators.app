# frozen_string_literal: true

# ValidatorBlockHistory
class ValidatorBlockHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  belongs_to :validator

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
end
