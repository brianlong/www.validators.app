# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_histories
#
#  id               :bigint           not null, primary key
#  account          :string(191)
#  active_stake     :bigint           unsigned
#  batch_uuid       :string(191)
#  commission       :decimal(10, )    unsigned
#  credits          :bigint           unsigned
#  delinquent       :boolean          default(FALSE)
#  last_vote        :bigint           unsigned
#  network          :string(191)
#  root_block       :bigint           unsigned
#  software_version :string(191)
#  vote_account     :string(191)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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
