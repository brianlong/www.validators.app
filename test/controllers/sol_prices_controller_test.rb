# frozen_string_literal: true

require "test_helper"

class SolPricesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sol_prices_url
    assert_response :success
  end
end
