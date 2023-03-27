# frozen_string_literal: true

class CommissionHistoryMailerPreview < ActionMailer::Preview
  def commission_change_info
    validator = Validator.first
    user = validator.watchers.first

    watchlist_el = UserWatchlistElement.first_or_create(
      validator: validator,
      user: user
    )
    commission_history = FactoryBot.create(:commission_history, validator: validator)

    CommissionHistoryMailer.commission_change_info(
      user: user,
      validator: validator,
      commission: commission_history
    )
  end
end
