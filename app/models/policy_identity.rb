# == Schema Information
#
# Table name: policy_identities
#
#  id           :bigint           not null, primary key
#  account      :string(191)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  policy_id    :bigint           not null
#  validator_id :bigint
#
# Indexes
#
#  index_policy_identities_on_policy_id     (policy_id)
#  index_policy_identities_on_validator_id  (validator_id)
#
# Foreign Keys
#
#  fk_rails_...  (policy_id => policies.id)
#  fk_rails_...  (validator_id => validators.id)
#
class PolicyIdentity < ApplicationRecord
  belongs_to :policy
  belongs_to :validator, optional: true

  scope :is_validator, -> { where.not(validator_id: nil) }
end
