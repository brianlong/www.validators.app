# frozen_string_literal: true

require "test_helper"

class RemoveUnconfirmedUsersTest < ActiveSupport::TestCase
  setup do
    @user1 = create(:user, created_at: 6.days.ago, confirmed_at: nil, email: "user1@test.com")
    @user2 = create(:user, created_at: 8.days.ago, confirmed_at: DateTime.now, email: "user2@test.com")
    @user3 = create(:user, created_at: 8.days.ago, confirmed_at: nil, email: "user3@test.com")
    @user4 = create(
      :user,
      created_at: 8.days.ago,
      confirmed_at: DateTime.now,
      email: "user3@test.com",
      last_sign_in_at: nil
    )
  end

  test "script deletes unconfirmed users after 7 days \
        and users who never signed in after 7 days" do
    load(Rails.root.join("script", "remove_unconfirmed_users.rb"))

    assert_equal 3, User.count
    assert User.all.include? @user1
    assert User.all.include? @user2
    refute User.all.include? @user3
    refute User.all.include? @user4
  end
end
