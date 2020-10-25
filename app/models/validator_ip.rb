# frozen_string_literal: true

# ValidatorIp
class ValidatorIp < ApplicationRecord
  belongs_to :validator
  after_save :copy_data_to_score

  def copy_data_to_score
    return if validator.validator_score_v1

    validator.validator_score_v1.ip_address = address
    validator.validator_score_v1.save
  end
end
