# frozen_string_literal: true

# ValidatorIp
class ValidatorIp < ApplicationRecord
  belongs_to :validator
  after_save :copy_data_to_score

  def copy_data_to_score
    if validator.validator_score_v1
      validator.validator_score_v1.ip_address = ip_address
      validator.validator_score_v1.save
    end
  end
end
