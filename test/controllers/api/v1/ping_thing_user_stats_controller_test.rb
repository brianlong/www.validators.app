# frozen_string_literal: true

require "test_helper"

class PingThingUserStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @headers = { "Token" => @user.api_token }

    @stats = create(:ping_thing_user_stat, user_id: @user.id)
  end

  test "GET api_v1_ping_thing_user_stats without token returns error" do
    get api_v1_ping_thing_user_stats_path(network: "testnet")
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, JSON.parse(@response.body)
  end

  test "GET api_v1_ping_thing_recent_stats with token returns 200 and correct response" do
    get api_v1_ping_thing_user_stats_path(
      network: "testnet"
    ), headers: @headers
    assert_response 200

    resp = JSON.parse(@response.body)

    refute resp["last_5_mins"].blank?
    assert_equal [@stats].to_json, resp["last_5_mins"]
  end
end
