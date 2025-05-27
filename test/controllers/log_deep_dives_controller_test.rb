# frozen_string_literal: true

require "test_helper"

class LogDeepDivesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get log_deep_dives_index_url
    assert_response :success
  end

  test "should get slot_72677728" do
    get log_deep_dives_slot_72677728_url
    assert_response :success
  end
end
