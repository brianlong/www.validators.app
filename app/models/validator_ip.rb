# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_ips
#
#  id                :bigint           not null, primary key
#  address           :string(191)
#  traits_ip_address :string(191)
#  traits_network    :string(191)
#  version           :integer          default(4)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  data_center_id    :bigint
#  validator_id      :bigint           not null
#
# Indexes
#
#  index_validator_ips_on_data_center_id                        (data_center_id)
#  index_validator_ips_on_validator_id                          (validator_id)
#  index_validator_ips_on_validator_id_and_version_and_address  (validator_id,version,address) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (data_center_id => data_centers.id)
#  fk_rails_...  (validator_id => validators.id)
#

class ValidatorIp < ApplicationRecord
  belongs_to :validator
  belongs_to :data_center, optional: true
  has_one :validator_score_v1, through: :validator
end
