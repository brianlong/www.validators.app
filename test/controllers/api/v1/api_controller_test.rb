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

  test 'post collector with valid data should succeed' do
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

  test 'GET validators with token should succeed' do
    get api_v1_validators_url(network: 'testnet'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal '1234', json.first['account']
  end

  test 'GET validator with token should succeed' do
    get api_v1_validators_url(network: 'testnet', account: '1234'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal '1234', json.first['account']
  end

  test 'GET api_v1_validators with token returns all data' do
    validator = create(:validator, :with_score, account: 'Test Account')
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)
    create(:ip, address: validator.score.ip_address)

    get api_v1_validators_url(network: 'testnet'),
        headers: { 'Token' => @user.api_token }
    assert_response 200

    json = response_to_json(@response.body)
    validator_with_all_data = json.select { |j| j['account'] == 'Test Account' }.first

    assert_equal 2, json.size

    # Adjust after adding/removing attributes in json builder
    assert_equal 29, validator_with_all_data.keys.size

    # Validator
    assert_equal 'testnet', validator_with_all_data['network']
    assert_equal 'john doe', validator_with_all_data['name']
    assert_equal 'johndoe', validator_with_all_data['keybase_id']

    # Score
    assert_equal 7, validator_with_all_data['total_score']
    assert_equal 1, validator_with_all_data['root_distance_score']
    assert_equal 2, validator_with_all_data['vote_distance_score']
    assert_equal 0, validator_with_all_data['skipped_slot_score']
    assert_equal '1.6.7', validator_with_all_data['software_version']
    assert_equal 2, validator_with_all_data['software_version_score']
    assert_equal 0, validator_with_all_data['stake_concentration_score']
    assert_nil validator_with_all_data['data_center_concentration_score']
    assert_equal 1, validator_with_all_data['published_information_score']
    assert_equal 1, validator_with_all_data['security_report_score']
    assert_equal 206_356_743_328_737, validator_with_all_data['active_stake']
    assert_equal 10, validator_with_all_data['commission']
    assert_equal false, validator_with_all_data['delinquent']
    assert_equal '23470-US-America/Chicago', validator_with_all_data['data_center_key']
    assert_nil validator_with_all_data['data_center_host']

    # Vote accounts
    assert_equal 'Test Account', validator_with_all_data['vote_account']

    # Report
    assert_equal 'skipped_slots', validator_with_all_data['skipped_slots']
    assert_equal 'skipped_slot_percent', validator_with_all_data['skipped_slot_percent']
    assert_nil validator_with_all_data['ping_time']

    # IP
    assert_equal 0, validator_with_all_data['autonomous_system_number']
  end

  test 'GET api_v1_validator with token returns all data' do
    validator = create(:validator, :with_score, account: 'Test Account')
    create(:vote_account, validator: validator)
    create(:report, :build_skipped_slot_percent)
    create(:ip, address: validator.score.ip_address)

    get api_v1_validator_url(
      network: 'testnet',
      account: validator.account
    ), headers: { 'Token' => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body)

    # Adjust after adding/removing attributes in json builder
    assert_equal 29, json_response.keys.size

    # Validator
    assert_equal 'testnet', json_response['network']
    assert_equal 'john doe', json_response['name']
    assert_equal 'johndoe', json_response['keybase_id']

    # Score
    assert_equal 7, json_response['total_score']
    assert_equal 1, json_response['root_distance_score']
    assert_equal 2, json_response['vote_distance_score']
    assert_equal 0, json_response['skipped_slot_score']
    assert_equal '1.6.7', json_response['software_version']
    assert_equal 2, json_response['software_version_score']
    assert_equal 0, json_response['stake_concentration_score']
    assert_nil json_response['data_center_concentration_score']
    assert_equal 1, json_response['published_information_score']
    assert_equal 1, json_response['security_report_score']
    assert_equal 206_356_743_328_737, json_response['active_stake']
    assert_equal 10, json_response['commission']
    assert_equal false, json_response['delinquent']
    assert_equal '23470-US-America/Chicago', json_response['data_center_key']
    assert_nil json_response['data_center_host']

    # Vote accounts
    assert_equal 'Test Account', json_response['vote_account']

    # Report
    assert_equal 'skipped_slots', json_response['skipped_slots']
    assert_equal 'skipped_slot_percent', json_response['skipped_slot_percent']
    assert_nil json_response['ping_time']

    # IP
    assert_equal 0, json_response['autonomous_system_number']
  end

  test 'GET api_v1_validator_block_history with token returns all data' do
    validator = create(:validator, :with_score, account: 'Test Account')
    create(:vote_account, validator: validator)
    create(:validator_block_history, validator: validator)

    get api_v1_validator_block_history_url(
      network: 'testnet',
      account: validator.account
    ), headers: { 'Token' => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body).first

    # Adjust after adding/removing attributes in json builder
    assert_equal 7, json_response.keys.size

    assert_nil json_response['epoch']
    assert_nil json_response['batch_uuid']
    assert_equal 1, json_response['leader_slots']
    assert_equal 1, json_response['blocks_produced']
    assert_equal 1, json_response['skipped_slots']
    assert_equal '0.25', json_response['skipped_slot_percent']
  end

  test 'request ping_times with token should show empty array' do
    get api_v1_ping_times_url(network: 'testnet', account: '1234'),
        headers: { 'Token' => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal 3, json.count
  end
end
