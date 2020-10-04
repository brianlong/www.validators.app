require 'test_helper'

class DataCentersControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get data_centers_url(network: 'testnet')
    assert_response :success
  end
end
