# frozen_string_literal: true

require "test_helper"

class UserWatchlistElementTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @validator = create(:validator)
  end

  test "similar watchlist element cannot be created twice" do
    create(:user_watchlist_element, user: @user, validator: @validator)

    assert_raises(ActiveRecord::RecordInvalid) do
      create(:user_watchlist_element, user: @user, validator: @validator)
    end
  end

  test "watchlist element needs to have a user" do
    assert_raises(ActiveRecord::RecordInvalid) do
      create(:user_watchlist_element, user: nil, validator: @validator)
    end
  end

  test "watchlist element needs to have a validator" do
    assert_raises(ActiveRecord::RecordInvalid) do
      create(:user_watchlist_element, user: @user, validator: nil)
    end
  end
end
