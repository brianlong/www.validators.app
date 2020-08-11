# frozen_string_literal: true

class ValidatorHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  def self.average_root_block_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).average(:root_block)
  end

  def self.highest_root_block_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).maximum(:root_block)
  end

  def self.median_root_block_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).median(:root_block)
  end

  def self.average_last_vote_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).average(:last_vote)
  end

  def self.highest_last_vote_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).maximum(:last_vote)
  end

  def self.median_last_vote_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).median(:last_vote)
  end
end
