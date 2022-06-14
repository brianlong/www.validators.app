# frozen_string_literal: true

require 'test_helper'

class YouControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, :confirmed)
  end

  test "index returns success for signed in user" do
    sign_in @user

    get user_root_url

    assert_response :success
  end

  test "index redirects if no signed in user" do
    get user_root_url

    assert_redirected_to new_user_session_path
    assert_match "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "regenerate_token redirects if no signed in user" do
    get user_root_url

    assert_redirected_to new_user_session_path
    assert_match "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "regenerate_token returns success for signed in user" do
    sign_in @user

    get user_root_url

    assert_response :success
  end
end
