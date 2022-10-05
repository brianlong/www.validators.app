# frozen_string_literal: true

# == Schema Information
#
# Table name: gossip_nodes
#
#  id               :bigint           not null, primary key
#  account          :string(191)
#  gossip_port      :integer
#  ip               :string(191)
#  network          :string(191)
#  software_version :string(191)
#  staked           :boolean          default(FALSE)
#  tpu_port         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_gossip_nodes_on_network_and_account  (network,account)
#  index_gossip_nodes_on_network_and_staked   (network,staked)
#

class GossipNode < ApplicationRecord
  FIELDS_FOR_API = [
    "account",
    "ip",
    "network",
    "staked",
    "software_version",
    "created_at",
    "updated_at"
  ].freeze

  has_one :validator_ip, primary_key: :ip, foreign_key: :address
  has_one :validator_ip_active, -> { active }, primary_key: :ip, foreign_key: :address, class_name: "ValidatorIp"
  has_one :data_center_host, through: :validator_ip_active
  has_one :data_center, -> { for_api }, through: :validator_ip_active
  has_one :validator, -> { for_api }, primary_key: :account, foreign_key: :account

  def add_validator_ip
    ValidatorIp.find_or_create_by(address: self.ip, is_active: true)
  end
end
