# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_things
#
#  id               :bigint           not null, primary key
#  amount           :bigint
#  application      :string(191)
#  commitment_level :integer
#  network          :string(191)
#  response_time    :integer
#  signature        :string(191)
#  success          :boolean          default(TRUE)
#  transaction_type :string(191)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_ping_things_on_network_and_transaction_type  (network,transaction_type)
#  index_ping_things_on_network_and_user_id           (network,user_id)
#  index_ping_things_on_user_id                       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThing < ApplicationRecord
  belongs_to :user

  enum commitment_level: { processed: 0, confirmed: 1, finalized: 2 }

  validates_presence_of :user_id, :response_time, :signature, :network
  validates_length_of :application, maximum: 80, allow_blank: true
  validates :network, inclusion: { in: %w(mainnet testnet) }
  validates :signature, length: { in: 64..128 }

  def to_builder
    Jbuilder.new do |ping_thing|
      ping_thing.(
        self,
        :application,
        :commitment_level,
        :created_at,
        :network,
        :response_time,
        :signature,
        :success,
        :transaction_type
      )
    end
  end
end
