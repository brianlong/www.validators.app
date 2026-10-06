# frozen_string_literal: true

# == Schema Information
#
# Table name: alpenglow_epoch_ranks
#
#  id                 :bigint           not null, primary key
#  bls_pubkey         :string(191)      not null
#  epoch              :integer          not null
#  finalized          :boolean          default(FALSE), not null
#  network            :string(191)      not null
#  rank               :integer          not null
#  stake              :bigint           not null
#  validator_identity :string(191)      not null
#  vote_account       :string(191)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_alpenglow_epoch_ranks_on_network_and_epoch_and_rank  (network,epoch,rank) UNIQUE
#  index_alpenglow_epoch_ranks_on_network_epoch_vote_account  (network,epoch,vote_account) UNIQUE
#
class AlpenglowEpochRank < ApplicationRecord
  validates :network, inclusion: { in: NETWORKS }
  validates :epoch, :rank, :vote_account, :validator_identity, :bls_pubkey, :stake, presence: true

  scope :for_epoch, ->(network, epoch) { where(network: network, epoch: epoch).order(:rank) }
  scope :finalized, -> { where(finalized: true) }
end
