require 'test_helper'

class SidekiqControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user_one  = create(:user)
    @admin_one = create(:user, :admin)
  end

  # Anonymous will be redirected before seeing a routing error.
  test 'anonymous should get redirected' do
    get sidekiq_web_path
    assert_redirected_to '/users/sign_in'
  end

  # Logged-in users will see a RoutingError
  test 'regular user should get redirected' do
    sign_in @user_one
    assert_equal '/users/sign_in', new_user_session_path
    assert_raises ActionController::RoutingError do
      get sidekiq_web_path
    end
  end

  # Admins can see Sidekiq Dashboard
  test 'the_truth' do
    sign_in @admin_one
    get sidekiq_web_path
    assert :success
  end
end
