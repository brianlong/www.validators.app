# == Schema Information
#
# Table name: group_validators
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :integer
#  validator_id :integer
#
class GroupValidator < ApplicationRecord
  belongs_to :group
  belongs_to :validator
end
