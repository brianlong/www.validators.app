# frozen_string_literal: true

# == Schema Information
#
# Table name: gossip_nodes
#
#  id          :bigint           not null, primary key
#  account     :string(191)
#  gossip_port :integer
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
#  index_gossip_nodes_on_network_and_account  (network,account)
#  index_gossip_nodes_on_network_and_staked   (network,staked)
#

class GossipNode < ApplicationRecord
  FIELDS_FOR_API = %w[
    identity
    ip
    network
    staked
    version
    created_at
  ].freeze

  has_one :validator_ip, primary_key: :ip, foreign_key: :address
  has_one :data_center, -> { for_api }, through: :validator_ip
  has_one :validator, -> { for_api }, primary_key: :identity, foreign_key: :account

  def add_validator_ip
    ValidatorIp.find_or_create_by(address: self.ip)
  end
end
