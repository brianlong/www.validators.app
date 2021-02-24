# ValidatorIp
class ValidatorIp < ApplicationRecord
  belongs_to :validator
  after_touch :copy_data_to_score

  def copy_data_to_score
    validator.copy_data_to_score
  end
end
