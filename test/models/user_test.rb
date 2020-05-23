# frozen_string_literal: true

require 'test_helper'

# UserTest
class UserTest < ActiveSupport::TestCase
  setup do
    @user_params = {
      username: 'test',
      email: 'test@test.com',
      password: 'password'
    }
  end

  test 'correctly creates user with username, encrypts email, creates hash' do
    assert_difference('User.count') do
      User.create(@user_params)
    end

    user = User.find_by(username: 'test')
    assert_equal user.username, 'test'
    refute_equal @user_params[:email], user.email_encrypted
    assert_equal user.email_hash, Digest::SHA256.hexdigest(@user_params[:email])
  end

  test '.search_by_email_hash' do
    User.create(@user_params)

    user = User.search_by_email_hash(@user_params[:email])
    assert_equal user.email, 'test@test.com'
  end

  test 'api_token is created with a new User' do
    # Show that the api_token is created with a new user
    u = User.create(@user_params)
    api_token = u.api_token
    assert_not_nil api_token

    # Save & reload the user to confirm that the token did not change
    u.update(username: 'test2')
    u.reload
    assert_equal 'test2', u.username
    assert_equal api_token, u.api_token
  end
end
