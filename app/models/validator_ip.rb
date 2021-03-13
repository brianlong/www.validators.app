# frozen_string_literal: true

# == Schema Information
#
# Table name: validator_ips
#
#  id           :bigint           not null, primary key
#  validator_id :bigint           not null
#  version      :integer          default(4)
#  address      :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_validator_ips_on_validator_id                          (validator_id)
#  index_validator_ips_on_validator_id_and_version_and_address  (validator_id,version,address) UNIQUE
#

class ValidatorIp < ApplicationRecord
  belongs_to :validator
  after_touch :copy_data_to_score

  def copy_data_to_score
    validator.copy_data_to_score
  end
end
