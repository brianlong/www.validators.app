# frozen_string_literal: true

# == Schema Information
#
# Table name: gossip_nodes
#
#  id          :bigint           not null, primary key
#  gossip_port :integer
#  identity    :string(191)
#  ip          :string(191)
#  network     :string(191)
#  staked      :boolean          default(FALSE)
#  tpu_port    :integer
#  version     :string(191)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_gossip_nodes_on_ip                    (ip)
#  index_gossip_nodes_on_network_and_identity  (network,identity)
#  index_gossip_nodes_on_network_and_staked    (network,staked)
#
class GossipNode < ApplicationRecord
  has_one :validator_ip, primary_key: :ip, foreign_key: :address
  has_one :data_center, through: :validator_ip

  def add_validator_ip
    ValidatorIp.find_or_create_by(address: self.ip)
  end
end
