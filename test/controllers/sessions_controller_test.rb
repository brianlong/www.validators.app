# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :confirmed, username: "tester", email: "tester@example.com")
  end

  test "signs in with username" do
    post user_session_path, params: { user: { login: "tester", password: "Password123" } }

    assert_redirected_to user_root_path
  end

  test "signs in with email" do
    post user_session_path, params: { user: { login: "tester@example.com", password: "Password123" } }

    assert_redirected_to user_root_path
  end

  test "does not sign in with wrong password" do
    post user_session_path, params: { user: { login: "tester@example.com", password: "wrong" } }

    assert_response :success
    assert_match "Invalid Username/email or password.", flash[:alert]
  end
end
