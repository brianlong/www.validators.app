# frozen_string_literal: true

# == Schema Information
#
# Table name: data_center_stats
#
#  id                        :bigint           not null, primary key
#  active_gossip_nodes_count :integer
#  active_validators_count   :integer
#  active_validators_stake   :float(24)        default(0.0)
#  gossip_nodes_count        :integer
#  network                   :string(191)
#  validators_count          :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  data_center_id            :bigint           not null
#
# Indexes
#
#  index_data_center_stats_on_data_center_id              (data_center_id)
#  index_data_center_stats_on_network_and_data_center_id  (network,data_center_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (data_center_id => data_centers.id)
#
class DataCenterStat < ApplicationRecord
  FIELDS_FOR_API = %w[active_gossip_nodes_count active_validators_count].freeze

  belongs_to :data_center

  validates_uniqueness_of :data_center, scope: [:network, :data_center_id]
end
