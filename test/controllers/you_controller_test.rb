# frozen_string_literal: true

require 'test_helper'

class YouControllerTest < ActionDispatch::IntegrationTest
  test 'Anonymous should not get index' do
    get user_root_url
    assert_response 302 # :success
  end
end
