# frozen_string_literal: true

# == Schema Information
#
# Table name: alpenglow_validator_epoch_stats
#
#  id                           :bigint           not null, primary key
#  divergent_skip_votes         :integer          default(0), not null
#  epoch                        :integer          not null
#  fast_final_signatures        :integer          default(0), not null
#  fast_finalized_slots         :integer          default(0), not null
#  last_block_user_agent        :string(191)
#  leader_fast_finalized        :integer          default(0), not null
#  leader_final_lag_sum         :bigint           default(0), not null
#  leader_slots                 :integer          default(0), not null
#  leader_slots_with_final_cert :integer          default(0), not null
#  leader_slow_finalized        :integer          default(0), not null
#  network                      :string(191)      not null
#  notar_reward_slots           :integer          default(0), not null
#  notar_votes                  :integer          default(0), not null
#  skip_votes                   :integer          default(0), not null
#  slow_final_signatures        :integer          default(0), not null
#  slow_finalized_slots         :integer          default(0), not null
#  slow_notar_signatures        :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  validator_id                 :bigint           not null
#  vote_account_id              :bigint           not null
#
# Indexes
#
#  index_alpenglow_val_epoch_stats_on_vote_account_id_epoch         (vote_account_id,epoch) UNIQUE
#  index_alpenglow_validator_epoch_stats_on_network_and_epoch       (network,epoch)
#  index_alpenglow_validator_epoch_stats_on_validator_id_and_epoch  (validator_id,epoch)
#
class AlpenglowValidatorEpochStat < ApplicationRecord
  RECENT_EPOCHS = 10

  belongs_to :vote_account
  belongs_to :validator

  validates :network, inclusion: { in: NETWORKS }
  validates :epoch, presence: true

  scope :for_network, ->(network) { where(network: network) }

  def self.recent_epochs(network, limit: RECENT_EPOCHS)
    for_network(network).distinct.order(epoch: :desc).limit(limit).pluck(:epoch)
  end

  def self.resolve_epoch(network, requested = nil)
    return requested.to_i if requested.present? && for_network(network).exists?(epoch: requested.to_i)

    for_network(network).maximum(:epoch)
  end
end
