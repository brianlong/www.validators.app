# frozen_string_literal: true

# == Schema Information
#
# Table name: cluster_stats
#
#  id                 :bigint           not null, primary key
#  network            :string(191)
#  nodes_count        :integer
#  software_version   :string(191)
#  total_active_stake :bigint
#  validator_count    :integer
#  root_distance      :json
#  skipped_slots      :json
#  skipped_votes      :json
#  total_active_stake :bigint
#  vote_distance      :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ClusterStat < ApplicationRecord
  serialize :root_distance, JSON
  serialize :vote_distance, JSON
  serialize :skipped_slots, JSON
  serialize :skipped_votes, JSON

  scope :by_network, -> (network) { where(network: network) }
end
