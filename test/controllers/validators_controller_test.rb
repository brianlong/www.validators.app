# frozen_string_literal: true

require 'test_helper'

# ValidatorsControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @validator = validators(:one)
  end

  test 'should get index' do
    get validators_url
    assert_response :success
  end

  test 'should show validator' do
    get validator_url(@validator)
    assert_response :success
  end
end
