# frozen_string_literal: true

# == Schema Information
#
# Table name: user_watchlist_elements
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#  validator_id :bigint           not null
#
# Indexes
#
#  index_user_watchlist_elements_on_user_id                   (user_id)
#  index_user_watchlist_elements_on_user_id_and_validator_id  (user_id,validator_id) UNIQUE
#  index_user_watchlist_elements_on_validator_id              (validator_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#  fk_rails_...  (validator_id => validators.id) ON DELETE => cascade
#
class UserWatchlistElement < ApplicationRecord
  belongs_to :user
  belongs_to :validator

  validates :validator_id, uniqueness: { scope: :user_id }
end
