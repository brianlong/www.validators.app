# frozen_string_literal: true

require 'test_helper'

class DataCentersControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get data_centers_url(network: 'testnet')
    assert_response :success
  end

  test "should get data_center" do
    dc = create(:data_center)

    get data_center_path(key: dc.data_center_key, network: 'testnet')
    assert_response :success
  end

  test "should get data_center with dots in key" do
    dc = create(:data_center, data_center_key: "123-AB/test.net.")

    get data_center_path(key: dc.data_center_key, network: 'testnet')
    assert_response :success
  end
end
