# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_ips
#
#  id                  :bigint           not null, primary key
#  address             :string(191)
#  is_active           :boolean          default(FALSE)
#  is_muted            :boolean          default(FALSE)
#  is_overridden       :boolean          default(FALSE)
#  traits_domain       :string(191)
#  traits_ip_address   :string(191)
#  traits_network      :string(191)
#  version             :integer          default(4)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  data_center_host_id :bigint
#  validator_id        :bigint
#
# Indexes
#
#  index_validator_ips_on_data_center_host_id                   (data_center_host_id)
#  index_validator_ips_on_is_active                             (is_active)
#  index_validator_ips_on_is_active_and_address                 (is_active,address)
#  index_validator_ips_on_validator_id_and_version_and_address  (validator_id,version,address) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (data_center_host_id => data_center_hosts.id)
#  fk_rails_...  (validator_id => validators.id)
#

class ValidatorIp < ApplicationRecord
  FIELDS_FOR_API = %i[
    address 
    data_center_host_id 
    id 
    validator_id
  ].freeze

  belongs_to :validator, optional: true
  belongs_to :gossip_node, primary_key: :ip, foreign_key: :address, optional: true
  belongs_to :data_center_host, optional: true
  has_one :validator_score_v1, through: :validator
  has_one :data_center, through: :data_center_host

  # API 
  belongs_to :data_center_host_for_api, -> { for_api },
    foreign_key: :data_center_host_id,
    class_name: "DataCenterHost", 
    optional: true

  after_touch :copy_data_to_score

  scope :active, -> { where(is_active: true) }
  scope :active_for_api, -> { select(FIELDS_FOR_API).active }

  def copy_data_to_score
    validator&.copy_data_to_score
  end

  def set_is_active
    return nil if is_active
    
    vips = ValidatorIp.where(validator_id: validator_id, is_active: true)
    vips.update(is_active: false)

    update(is_active: true)
  end
end
