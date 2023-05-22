# frozen_string_literal: true

# == Schema Information
#
# Table name: cluster_stats
#
#  id                 :bigint           not null, primary key
#  epoch_duration     :float(24)
#  network            :string(191)
#  nodes_count        :integer
#  roi                :float(24)
#  root_distance      :json
#  skipped_slots      :json
#  skipped_votes      :json
#  software_version   :string(191)
#  total_active_stake :bigint
#  validator_count    :integer
#  vote_distance      :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_cluster_stat_on_network  (network)
#
class ClusterStat < ApplicationRecord
  scope :by_network, -> (network) { where(network: network) }
end
