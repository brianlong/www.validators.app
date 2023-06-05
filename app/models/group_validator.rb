# frozen_string_literal: true

# == Schema Information
#
# Table name: group_validators
#
#  id           :bigint           not null, primary key
#  link_reason  :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :integer
#  validator_id :integer
#
# Indexes
#
#  index_group_validators_on_group_id      (group_id)
#  index_group_validators_on_validator_id  (validator_id)
#
class GroupValidator < ApplicationRecord
  belongs_to :group
  belongs_to :validator

  serialize :link_reason, JSON
end
