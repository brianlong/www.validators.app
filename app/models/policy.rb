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
#  network    :string(191)
#  owner      :string(191)
#  pubkey     :string(191)      not null
#  rent_epoch :string(191)
#  strategy   :boolean
#  url        :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_policies_on_pubkey  (pubkey) UNIQUE
#
class Policy < ApplicationRecord
  has_many :policy_identities, dependent: :destroy
  has_many :validators, through: :policy_identities
end
