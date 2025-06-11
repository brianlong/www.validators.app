# == Schema Information
#
# Table name: policies
#
#  id         :bigint           not null, primary key
#  executable :boolean
#  kind       :boolean
#  lamports   :bigint
#  mint       :string(191)
#  name       :string(191)
#  owner      :string(191)
#  rent_epoch :bigint
#  strategy   :boolean
#  url        :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Policy < ApplicationRecord
  has_many :validator_policies, dependent: :destroy
  has_many :validators, through: :validator_policies
end
