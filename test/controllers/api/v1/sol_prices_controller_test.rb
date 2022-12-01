# frozen_string_literal: true

require "test_helper"

class SolPricesControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @user = create(:user)
    @headers = { "Token" => @user.api_token }
    35.times do |n|
      create(:sol_price, :coin_gecko, datetime_from_exchange: n.days.ago)
    end
  end

  test "GET api_v1_sol_prices without token returns error" do
    get api_v1_sol_prices_path
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "GET api_v1_sol_prices with token returns 200" do
    get api_v1_sol_prices_path, headers: @headers
    assert_response 200
  end

  test "GET api_v1_sol_prices without params returns results for default params" do
    get api_v1_sol_prices_path, headers: @headers
    parsed_response = JSON.parse(@response.body)

    assert_response 200
    assert_equal 31, JSON.parse(@response.body).size
    assert_equal "coin_gecko", parsed_response.last["exchange"]
  end

  test "GET api_v1_sol_prices with from and to params returns correct results" do
    get api_v1_sol_prices_path(from: 10.days.ago, to: 8.days.ago), headers: @headers

    assert_response 200
    assert_equal 3, JSON.parse(@response.body).size
  end

  test "GET api_v1_sol_prices with incorrect exchange returns error" do
    create(:sol_price, :coin_gecko)

    get api_v1_sol_prices_path(exchange: "wrong_exchange"), headers: @headers
    parsed_response = JSON.parse(@response.body)
    expected_response = { "error" => "invalid exchange" }

    assert_response 422
    assert_equal expected_response, parsed_response
  end
end
