# frozen_string_literal: true

require "test_helper"

class AlpenglowControllerTest < ActionDispatch::IntegrationTest
  test "index renders the page with the cluster stats component" do
    get alpenglow_url(network: "alpenglow-community")

    assert_response :success
    assert_includes response.body, "Alpenglow Stats"
    assert_includes response.body, 'id="alpenglow-cluster-stats-component"'
  end
end
