# frozen_string_literal: true

require 'test_helper'

class EpochsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user_params = {
      username: 'test',
      email: 'test@test.com',
      password: 'password'
    }
    @user = User.create(@user_params)

    create(:epoch_wall_clock, epoch: 101)
    create(:epoch_wall_clock, epoch: 100)
    create(:epoch_wall_clock, epoch: 102)
  end

  test 'request without token should get error' do
    get api_v1_epoch_last_url
    assert_response 401
    expected_response = { 'error' => 'Unauthorized' }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'request with token should succeed' do
    get api_v1_epoch_last_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    assert_response 200
  end

  test 'get last epoch by network success' do
    get api_v1_epoch_last_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 102, resp['epoch']
    assert_equal %w[
      epoch
      starting_slot
      slots_in_epoch
      network
      created_at
    ].sort, resp.keys.sort
  end

  test 'get last epoch by network no params' do
    get api_v1_epoch_last_url, headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)
    expected_response = { "status" => "Parameter Missing" }
    assert_response 400
    assert_equal expected_response, resp
  end

  test 'get all epochs by network success' do
    get api_v1_epoch_all_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 3, resp.count
    assert_equal %w[
      epoch
      starting_slot
      slots_in_epoch
      network
      created_at
    ].sort, resp[0].keys.sort
  end

  def response_to_json(response)
    JSON.parse(response)
  end
end
