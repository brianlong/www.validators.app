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
    assert_equal 1, resp.keys.count
    assert_equal 6, resp["data_centers_groups"].values.first.keys.count
  end

  test "#data_centers_with_nodes response returns correct sums for data center groups" do
    dc = create(:data_center, :frankfurt, country_name: @data_center.country_name)
    create(
      :data_center_stat,
      data_center: dc,
      network: @network,
      active_gossip_nodes_count: 2,
      active_validators_count: 2
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 1, resp.keys.count
    assert_equal 3, resp["data_centers_groups"].values.last["active_gossip_nodes_count"]
    assert_equal 3, resp["data_centers_groups"].values.last["active_validators_count"]
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
    assert_equal 1, resp.keys.count
    assert_equal 1, resp["data_centers_groups"].values.last["active_gossip_nodes_count"]
    assert_equal 1, resp["data_centers_groups"].values.last["active_validators_count"]
  end

  test "#data_centers_with_nodes response does not include unknown data center" do
    unknown_dc = create(:data_center, city_name: "Unknown",
                        traits_autonomous_system_number: 0)
    create(
      :data_center_stat,
      data_center: unknown_dc,
      network: @network
    )

    get api_v1_data_centers_with_nodes_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 1, resp.keys.count
    refute resp["data_centers_groups"].values.flat_map{|dc| dc["data_centers"]}.include? "0--Unknown"
  end

  test "#data_center_stats request with token returns success" do
    get api_v1_data_center_stats_url(network: @network), headers: @headers
    assert_response 200
  end

  test "#data_center_stats request without token returns error" do
    get api_v1_data_center_stats_url(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized"  }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "#data_center_stats returns stats by country and organization" do
    data_center2 = create(:data_center, :frankfurt)
    data_center_stats2 = create(
      :data_center_stat,
      data_center: data_center2,
      network: @network,
      active_gossip_nodes_count: 13,
      active_validators_count: 2
    )

    data_center3 = create(:data_center, :china)
    data_center_stats3 = create(
      :data_center_stat,
      data_center: data_center3,
      network: @network,
      active_gossip_nodes_count: 8,
      active_validators_count: 5
    )

    get api_v1_data_center_stats_url(network: @network), headers: @headers
    resp = JSON.parse(@response.body)
    
    assert_response 200
    assert_equal ["China", 5], resp["dc_by_country"][0]
    assert_equal ["Germany", 3], resp["dc_by_country"][1]
    assert_equal ["Chinese Organisation", 5], resp["dc_by_organization"][0]
    assert_equal ["Germany Organisation", 3], resp["dc_by_organization"][1]
  end
end
