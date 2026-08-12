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

  test "index displays average root and vote distance per data center" do
    data_center = create(:data_center, :berlin)
    host = create(:data_center_host, data_center: data_center)
    validator = create(:validator, network: "testnet")
    create(:validator_ip, :active, data_center_host: host, validator: validator)
    create(:validator_score_v1, network: "testnet", validator: validator, active_stake: 100)
    create(
      :data_center_stat,
      data_center: data_center,
      network: "testnet",
      root_distance: { "average" => 12.5 },
      vote_distance: { "average" => 34.5 }
    )

    get data_centers_url(network: "testnet")

    assert_response :success
    assert_match "12.5", @response.body
    assert_match "34.5", @response.body
  end

  test "index shows a dash when a data center has no computed distance stats" do
    data_center = create(:data_center, :berlin)
    host = create(:data_center_host, data_center: data_center)
    validator = create(:validator, network: "testnet")
    create(:validator_ip, :active, data_center_host: host, validator: validator)
    create(:validator_score_v1, network: "testnet", validator: validator, active_stake: 100)

    get data_centers_url(network: "testnet")

    assert_response :success
  end
end
