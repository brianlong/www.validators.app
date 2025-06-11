# == Schema Information
#
# Table name: validator_policies
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  policy_id    :bigint           not null
#  validator_id :bigint           not null
#
# Indexes
#
#  index_validator_policies_on_policy_id     (policy_id)
#  index_validator_policies_on_validator_id  (validator_id)
#
# Foreign Keys
#
#  fk_rails_...  (policy_id => policies.id)
#  fk_rails_...  (validator_id => validators.id)
#
class ValidatorPolicy < ApplicationRecord
  belongs_to :policy
  belongs_to :validator
end
