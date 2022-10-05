# frozen_string_literal: true

# == Schema Information
#
# Table name: data_center_hosts
#
#  id             :bigint           not null, primary key
#  host           :string(191)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  data_center_id :bigint
#
# Indexes
#
#  index_data_center_hosts_on_data_center_id_and_host  (data_center_id,host) UNIQUE
#
class DataCenterHost < ApplicationRecord
  FIELDS_FOR_API = %i[
    data_center_id
    host
    id
  ].freeze

  belongs_to :data_center
  has_many :validator_ips, dependent: :nullify
  has_many :validator_ips_active, -> { active }, class_name: "ValidatorIp"
  has_many :validators, through: :validator_ips_active
  has_many :gossip_nodes, through: :validator_ips_active
  has_many :validator_score_v1s, through: :validators

  # API
  belongs_to :data_center_for_api, -> { for_api }, 
    foreign_key: :data_center_id, 
    class_name: "DataCenter"

  scope :for_api, -> { select(FIELDS_FOR_API) }

  delegate :data_center_key, to: :data_center

  def to_builder
    Jbuilder.new do |data_center_host|
      data_center_host.data_center_host self.host
    end
  end
end
