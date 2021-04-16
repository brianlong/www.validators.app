# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_histories
#
#  id               :bigint           not null, primary key
#  network          :string(255)
#  batch_uuid       :string(255)
#  account          :string(255)
#  vote_account     :string(255)
#  commission       :decimal(10, )    unsigned
#  last_vote        :bigint           unsigned
#  root_block       :bigint           unsigned
#  credits          :bigint           unsigned
#  active_stake     :bigint           unsigned
#  delinquent       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  software_version :string(255)
#
# Indexes
#
#  index_validator_histories_on_network_and_account_and_id  (network,account,id)
#  index_validator_histories_on_network_and_batch_uuid      (network,batch_uuid)
#
class ValidatorHistory < ApplicationRecord
  # Use the monkey patch for median
  include PipelineLogic

  def self.average_root_block_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).average(:root_block)
  end

  # average distance of blocks for the given batch
  def self.average_root_block_distance_for(network, batch_uuid)
    highest_block = highest_root_block_for(network, batch_uuid)
    root_blocks = where(
      network: network,
      batch_uuid: batch_uuid
    ).pluck(:root_block)
    if !root_blocks.empty?
      # sum the distances instead of core values
      root_blocks_distance_sum = root_blocks.inject(0) do |sum, val|
        sum + (highest_block - val)
      end
      root_blocks_distance_sum / root_blocks.count.to_f
    else
      0
    end
  end

  # average distance of votes for the given batch
  def self.average_last_vote_distance_for(network, batch_uuid)
    highest_vote = highest_last_vote_for(network, batch_uuid)
    last_votes = where(
      network: network,
      batch_uuid: batch_uuid
    ).pluck(:last_vote)
    if !last_votes.empty?
      last_votes_distance_sum = last_votes.inject(0) do |sum, val|
        sum + (highest_vote - val)
      end
      last_votes_distance_sum / last_votes.count.to_f
    else
      0
    end
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

  def self.total_active_stake_for(network, batch_uuid)
    where(network: network, batch_uuid: batch_uuid).sum(:active_stake)
  end
end
