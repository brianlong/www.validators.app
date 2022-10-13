# frozen_string_literal: true

require "test_helper"

# ApiControllerTest
class DataCentersControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @network = "testnet"
    @data_center = create(:data_center, :berlin)
    data_center_stats = create(
      :data_center_stat,
      data_center: @data_center,
      network: @network,
      active_gossip_nodes_count: 1,
      active_validators_count: 1
    )

    @user = create(:user)
    @headers = { "Token" => @user.api_token }
  end

  test "#data_centers_with_nodes request without token returns error" do
    get api_v1_data_centers_with_nodes_url(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized"  }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "#data_centers_with_nodes request with token returns success" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    assert_response 200
  end

  test "#data_centers_with_nodes response has correct fields" do
    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 3, resp.keys.count
    assert_equal 7, resp["data_centers"].first.keys.count
  end

  test "#data_centers_with_nodes response does not include data_centers with 0 validators and 0 nodes" do
    empty_dc = create(:data_center)
    create(
      :data_center_stat,
      data_center: empty_dc,
      network: @network,
      active_gossip_nodes_count: 0,
      active_validators_count: 0
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 3, resp.keys.count
    assert_equal 1, resp["data_centers"].first["active_gossip_nodes_count"]
    assert_equal 1, resp["data_centers"].first["active_validators_count"]
  end

  test "#data_centers_with_nodes response does not include unknown data center" do
    unknown_dc = create(:data_center, city_name: "Unknown",
                        traits_autonomous_system_number: 0)
    create(
      :data_center_stat,
      data_center: unknown_dc,
      network: @network,
      gossip_nodes_count: 0,
      validators_count: 1
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 3, resp.keys.count
    refute resp["data_centers"].map{|dc| dc["data_center_key"]}.include? "0--Unknown"
  end

  test "#data_centers_with_nodes response returns correct validators and nodes sums" do
    data_center_frankfurt = create(:data_center, :frankfurt)
    create(
      :data_center_stat,
      data_center: data_center_frankfurt,
      network: @network,
      active_gossip_nodes_count: 6,
      active_validators_count: 4
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 3, resp.keys.count
    assert_equal 5, resp["total_active_validators_count"]
    assert_equal 7, resp["total_active_nodes_count"]
  end
end
