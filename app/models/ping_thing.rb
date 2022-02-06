# == Schema Information
#
# Table name: ping_things
#
#  id               :bigint           not null, primary key
#  amount           :bigint
#  response_time    :integer
#  signature        :string(191)
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

  POSSIBLE_TRANSACTION_TYPES = ['transfer']

  belongs_to :user

  validate_presence_of :user_id, :response_time
  validates :signature, , length: { in: 64..128 }

  class << self
    def attributes_from_raw(json_data, token)
      params = JSON.parse(json_data).symbolize_keys
      user_id = User.find_by(api_token: token)&.id
      transaction_type = if params[:transaction_type].in? POSSIBLE_TRANSACTION_TYPES
        params[:transaction_type]
      else
        nil
      end

      {
        amount: params[:amount].to_i,
        response_time: params[:time].to_i,
        signature: params[:signature],
        transaction_type: transaction_type,
        user_id: user_id
      }
    end
  end
end
