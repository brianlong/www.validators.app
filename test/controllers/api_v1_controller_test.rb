# frozen_string_literal: true

require 'test_helper'

# ApiControllerTest
class ApiControllerTest < ActionDispatch::IntegrationTest

  include ResponseHelper

  def setup
    @user_params = {
      username: 'test',
      email: 'test@test.com',
      password: 'password'
    }
    @user = User.create(@user_params)
  end

  test 'request ping without token should get error' do
    get api_v1_ping_url
    assert_response 401
    expected_response = { 'error' => 'Unauthorized' }
    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'request ping with token should succeed' do
    get api_v1_ping_url, headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal 'pong', json['answer']
  end

  test 'post collector without token should get error' do
    post api_v1_collector_url, params: {}
    assert_response 401
    expected_response = { 'error' => 'Unauthorized' }
    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'post collector with empty params should get error' do
    expected_response = { 'status' => 'Parameter Missing' }

    # Completely empty params
    post api_v1_collector_url,
         headers: { 'Token' => @user.api_token },
         params: {}
    assert_response 400
    assert_equal expected_response, response_to_json(@response.body)

    # Empty collector params
    post api_v1_collector_url,
         headers: { 'Token' => @user.api_token },
         params: { collector: {} }
    assert_response 400
    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'post collector with invalid params should get error' do
    post api_v1_collector_url,
         headers: { 'Token' => @user.api_token },
         params: { collector: { one: 1, two: 2, three: 3 } }
    assert_response 400
    expected_response = { 'status' => 'Bad Request' }
    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'collector with valid data should succeed' do
    # Prepare the payload
    valid_payload = {
      payload_type: 'ping',
      payload_version: 1,
      payload: { 'test_key' => 'test_value' }.to_json
    }

    # Post the payload
    post api_v1_collector_url,
         headers: { 'Token' => @user.api_token },
         params: { collector: valid_payload }
    assert_response 202
    json = response_to_json(@response.body)
    assert_equal 'Accepted', json['status']

    # Verify that the record was saved successfully
    collector = Collector.last
    assert_equal 'ping', collector.payload_type
    assert_equal 1, collector.payload_version
    assert_equal '{"test_key":"test_value"}', collector.payload
  end

  test 'request validators with token should succeed' do
    get api_v1_validators_url(network: 'testnet'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal '1234', json.first['account']
  end

  test 'request validator with token should succeed' do
    get api_v1_validators_url(network: 'testnet', account: '1234'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal '1234', json.first['account']
  end

  test 'request ping_times with token should show empty array' do
    get api_v1_ping_times_url(network: 'testnet', account: '1234'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal 3, json.count
  end
end
