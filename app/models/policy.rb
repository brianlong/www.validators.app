# == Schema Information
#
# Table name: policies
#
#  id         :bigint           not null, primary key
#  executable :boolean
#  kind       :integer
#  lamports   :bigint
#  mint       :string(191)
#  name       :string(191)
#  network    :string(191)
#  owner      :string(191)
#  pubkey     :string(191)      not null
#  rent_epoch :string(191)
#  strategy   :boolean
#  symbol     :string(191)
#  url        :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_policies_on_network_and_kind  (network,kind)
#  index_policies_on_pubkey            (pubkey) UNIQUE
#
class Policy < ApplicationRecord
  has_many :policy_identities, dependent: :destroy
  has_many :validators, through: :policy_identities

  validates :pubkey, presence: true, uniqueness: true

  enum kind: { v1: 0, v2: 1 }

  #default_scope { where(kind: :v2) }
  scope :v2, -> { where(kind: :v2) }

  FIELDS_FOR_API = %i[
    pubkey
    owner
    lamports
    rent_epoch
    kind
    strategy
    executable
    network
    url
    mint
    name
  ].freeze

  def to_builder
    Jbuilder.new do |json|
      json.extract! self, *FIELDS_FOR_API
      json.identities_count policy_identities.count
    end
  end

  def non_validators
    policy_identities.where(validator_id: nil)
  end
end
