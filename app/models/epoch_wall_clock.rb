# frozen_string_literal: true

# == Schema Information
#
# Table name: epoch_wall_clocks
#
#  id             :bigint           not null, primary key
#  ending_slot    :bigint
#  epoch          :integer
#  network        :string(191)
#  slots_in_epoch :integer
#  starting_slot  :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_epoch_wall_clocks_on_epoch              (epoch)
#  index_epoch_wall_clocks_on_network_and_epoch  (network,epoch) UNIQUE
#
class EpochWallClock < ApplicationRecord
  validates :network, :epoch, presence: true

  scope :by_network, ->(network) { where(network: network).order(epoch: :desc) }

  after_create :track_commission_changes

  def track_commission_changes
    if self.network == "mainnet"
      current_batch_uuid = Batch.last_scored(self.network)&.uuid
      TrackCommissionChangesWorker.set(
        wait_until: 1.hour,
        queue: "high_priority"
      ).perform_async({current_batch_uuid: current_batch_uuid})
    end
  end
end
