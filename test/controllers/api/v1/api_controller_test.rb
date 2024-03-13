# frozen_string_literal: true

require "test_helper"
require "rack/cors"
require "rack/test"

# ApiControllerTest
class ApiControllerTest < ActionDispatch::IntegrationTest

  include ResponseHelper

  def setup
    @user_params = {
      username: "test",
      email: "test@test.com",
      password: "password"
    }
    @user = User.create(@user_params)
  end

  test "When reaching the api \
        from origin listed in whitelist \
        should return 200" do
    get api_v1_ping_url, headers: {
      "Origin" => "http://example.com" # this origin is in whitelist
    }

    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end

  test "When reaching the api \
        from foreign origin \
        should return Unauthorized" do
    get api_v1_ping_url, headers: {
      "Origin" => "http://foreign.com"
    }

    assert_response 401
    json = response_to_json(@response.body)
    assert_equal "Unauthorized", json["error"]
  end

  test "When reaching the api \
  from foreign origin but with correct token \
  should return 200" do
    get api_v1_ping_url, headers: {
      "Token" => @user.api_token,
      "Origin" => "http://foreign.com"
    }

    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end

  test "GET api_v1_ping without token should get error" do
    get api_v1_ping_url
    assert_response 401
    expected_response = { "error" => "Unauthorized" }
    assert_equal expected_response, response_to_json(@response.body)
  end

  test "GET api_v1_ping with token should succeed" do
    get api_v1_ping_url, headers: { "Token" => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end
end
