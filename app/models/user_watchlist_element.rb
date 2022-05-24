# == Schema Information
#
# Table name: user_watchlist_elements
#
#  id           :bigint           not null, primary key
#  network      :string(191)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#  validator_id :bigint           not null
#
# Indexes
#
#  index_user_watchlist_elements_on_user_id       (user_id)
#  index_user_watchlist_elements_on_validator_id  (validator_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (validator_id => validators.id)
#
class UserWatchlistElement < ApplicationRecord
  belongs_to :user
  belongs_to :validator
end
