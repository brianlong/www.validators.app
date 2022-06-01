# frozen_string_literal: true

require "test_helper"

class UserWatchlistElementTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @validator = create(:validator)
    @user_watchlist_element = build(:user_watchlist_element, user: @user, validator: @validator)
  end

  test "similar watchlist element cannot be created twice" do
    @user_watchlist_element.save
    
    assert_raises(ActiveRecord::RecordInvalid) do
      create(:user_watchlist_element, user: @user, validator: @validator)
    end
  end

  test "watchlist element needs to have a user" do
    @user_watchlist_element.user = nil
    refute @user_watchlist_element.valid?
  end

  test "watchlist element needs to have a validator" do
    @user_watchlist_element.validator = nil
    refute @user_watchlist_element.valid?
  end
end
