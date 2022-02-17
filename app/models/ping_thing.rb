# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_things
#
#  id               :bigint           not null, primary key
#  amount           :bigint
#  network          :string(191)
#  reported_at      :datetime
#  response_time    :integer
#  signature        :string(191)
#  transaction_type :string(191)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_ping_things_on_created_at_and_network_and_transaction_type  (created_at,network,transaction_type)
#  index_ping_things_on_created_at_and_network_and_user_id           (created_at,network,user_id)
#  index_ping_things_on_reported_at                                  (reported_at)
#  index_ping_things_on_user_id                                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThing < ApplicationRecord

  belongs_to :user

  validates_presence_of :user_id, :response_time, :signature, :network
  validates :network, inclusion: { in: %w(mainnet testnet) }
  validates :signature, length: { in: 64..128 }

end
