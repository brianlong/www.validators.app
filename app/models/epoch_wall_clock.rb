# frozen_string_literal: true

# == Schema Information
#
# Table name: epoch_wall_clocks
#
#  id                 :bigint           not null, primary key
#  ending_slot        :bigint
#  epoch              :integer
#  network            :string(191)
#  slots_in_epoch     :integer
#  starting_slot      :bigint
#  total_active_stake :bigint
#  total_rewards      :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_epoch_wall_clocks_on_epoch              (epoch)
#  index_epoch_wall_clocks_on_network_and_epoch  (network,epoch) UNIQUE
#
class EpochWallClock < ApplicationRecord
  validates :network, :epoch, presence: true

  scope :by_network, ->(network) { where(network: network).order(epoch: :desc) }
end
