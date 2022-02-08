# == Schema Information
#
# Table name: ping_things
#
#  id               :bigint           not null, primary key
#  amount           :bigint
#  network          :string(191)
#  response_time    :integer
#  signature        :string(191)
#  token            :string(191)
#  transaction_type :string(191)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_ping_things_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThing < ApplicationRecord

  belongs_to :user

  validates_presence_of :user_id, :response_time, :signature, :token, :network
  validates :signature, length: { in: 64..128 }

end
