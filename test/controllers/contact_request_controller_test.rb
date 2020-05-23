require 'test_helper'

class ContactRequestControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    @admin = create(:user, :admin)
  end

  test 'should redirect when non admin is logged in' do
    sign_in @user
    get contact_requests_url
    assert_redirected_to root_path + '?locale=en'
  end

  test 'should get index when admin is logged in' do
    sign_in @admin
    get contact_requests_url
    assert_response :success
  end
end
