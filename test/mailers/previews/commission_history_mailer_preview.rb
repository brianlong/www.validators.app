# frozen_string_literal: true

class CommissionHistoryMailerPreview < ActionMailer::Preview
  def commission_change_info
    watchlist_el = UserWatchlistElement.first
    val = watchlist_el.validator
    
    CommissionHistoryMailer.commission_change_info(validator: val, commission: val.commission_histories.first)
  end
end
