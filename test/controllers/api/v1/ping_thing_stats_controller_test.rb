# frozen_string_literal: true

require "test_helper"

class PingThingStatsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)
    @headers = { "Token" => @user.api_token }
    @ping_thing_stats = create_list(:ping_thing_stat, 60) 
  end

  test "GET api_v1_ping_thing_stats without token returns error" do
    get api_v1_ping_thing_stats_path(network: "testnet", interval: 1)
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "GET api_v1_ping_thing with token returns 200 and saves the data" do
    get api_v1_ping_thing_stats_path(
      network: "testnet", 
      interval: 1
    ), headers: @headers, params: @params_sample

    assert_response 200
    assert_equal 60, response_to_json(@response.body).size
  end

  test "GET api_v1_ping_thing_stats with token as csv returns 200" do
    path = api_v1_ping_thing_stats_path(
      network: "testnet",
      interval: 1,
      format: "csv"
    )
    get path, headers: @headers

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 61

    headers = PingThingStat::FIELDS_FOR_API.map(&:to_s)
    assert_equal csv.first, headers
  end
end
