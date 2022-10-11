# frozen_string_literal: true

# == Schema Information
#
# Table name: cluster_stats
#
#  id                 :bigint           not null, primary key
#  network            :string(191)
#  total_active_stake :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ClusterStat < ApplicationRecord
  scope :by_network, -> (network) { where(network: network) }
end
