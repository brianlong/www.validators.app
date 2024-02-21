require 'test_helper'

class OptOutRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, :confirmed)
    @admin = create(:user, :admin, :confirmed)
    @opt_out_params = {
      opt_out_request: {
        name: 'John Doe',
        request_type: 'opt_out',
        street_address: '2575 Pearl St, Ste 230',
        city: 'Boulder',
        postal_code: '80302',
        state: 'CO'
      }
    }
    @opt_out_request = create :opt_out_request
  end

  test 'not admin does not get index when non admin is logged in' do
    sign_in @user
    get opt_out_requests_path
    assert_redirected_to root_path
  end

  test 'not admin does not delete when non admin is logged in' do
    sign_in @user
    assert_no_difference('OptOutRequest.count') do
      delete opt_out_request_path @opt_out_request
    end
    assert_redirected_to root_path
  end

  test 'admin gets index when admin is logged in' do
    sign_in @admin
    get opt_out_requests_path
    assert_response :success
    assert_template :index
  end

  test 'admin deletes opt-out request' do
    sign_in @admin
    assert_difference('OptOutRequest.count', -1) do
      delete opt_out_request_path @opt_out_request
    end
    assert_redirected_to opt_out_requests_path
  end

  test 'guest does not get index' do
    get opt_out_requests_path
    assert_redirected_to root_path
  end

  test 'guest does not delete request' do
    assert_no_difference('OptOutRequest.count') do
      delete opt_out_request_path @opt_out_request
    end
    assert_redirected_to root_path
  end

  test 'guest gets opt_out form' do
    get '/opt-out-requests/new'
    assert_response :success
    assert_template :new
  end

  test 'guest creates opt-out request with correct params' do
    assert_difference('OptOutRequest.count') do
      post '/opt-out-requests', params: @opt_out_params
    end
    assert_redirected_to thank_you_opt_out_requests_path
  end

  test 'guest does not create opt-out request with incorrect params' do
    @opt_out_params[:opt_out_request][:state] = ''
    assert_no_difference('OptOutRequest.count') do
      post '/opt-out-requests', params: @opt_out_params
      assert_response :success
      assert_template :new
    end
  end
end
