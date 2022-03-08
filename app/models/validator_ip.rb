# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_ips
#
#  id                  :bigint           not null, primary key
#  address             :string(191)
#  is_active           :boolean          default(FALSE)
#  is_overridden       :boolean          default(FALSE)
#  traits_domain       :string(191)
#  traits_ip_address   :string(191)
#  traits_network      :string(191)
#  version             :integer          default(4)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  data_center_host_id :bigint
#  validator_id        :bigint           not null
#
# Indexes
#
#  index_validator_ips_on_data_center_host_id                   (data_center_host_id)
#  index_validator_ips_on_is_active                             (is_active)
#  index_validator_ips_on_validator_id                          (validator_id)
#  index_validator_ips_on_validator_id_and_version_and_address  (validator_id,version,address) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (data_center_host_id => data_center_hosts.id)
#  fk_rails_...  (validator_id => validators.id)
#

class ValidatorIp < ApplicationRecord
  belongs_to :validator
  belongs_to :data_center_host, optional: true
  has_one :data_center, through: :data_center_host

  after_touch :copy_data_to_score

  def copy_data_to_score
    validator.copy_data_to_score
  end

  def set_is_active
    return nil if is_active
    
    vips = ValidatorIp.where(validator_id: validator_id, is_active: true)
    vips.update(is_active: false)

    update(is_active: true)
  end
end
