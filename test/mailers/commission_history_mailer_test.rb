# frozen_string_literal: true

require "test_helper"

class CommissionHistoryMailerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @validator = create(:validator, :with_score)
    @commission_history = create(:commission_history, validator: @validator)
    @user = create(:user)

    create(:user_watchlist_element, user: @user, validator: @validator)
    @validator.reload
  end

  test "#commission_change_info sends email to a watcher" do
    assert_emails 1 do
      CommissionHistoryMailer.commission_change_info(
        user: @user,
        validator: @validator,
        commission: @commission_history
      ).deliver_now
    end
  end

  test "#commission_change_info raises error when user is not valid" do
    usr = create(:user)
    assert_raises RuntimeError, "invalid user" do
      CommissionHistoryMailer.commission_change_info(
        user: usr,
        validator: @validator,
        commission: @commission_history
      ).deliver_now
    end
  end
end
