# frozen_string_literal: true

# == Schema Information
#
# Table name: epoch_wall_clocks
#
#  id             :bigint           not null, primary key
#  ending_slot    :bigint
#  epoch          :integer
#  network        :string(255)
#  slots_in_epoch :integer
#  starting_slot  :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_epoch_wall_clocks_on_network_and_epoch  (network,epoch) UNIQUE
#
class EpochWallClock < ApplicationRecord
  validates :network, :epoch, presence: true

  scope :by_network, ->(network) { where(network: network).order(epoch: :asc) }

  def self.last_by_network(network)
    by_network(network).last
  end
end
