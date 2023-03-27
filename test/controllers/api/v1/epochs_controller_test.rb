# frozen_string_literal: true

require 'test_helper'

class EpochsControllerTest < ActionDispatch::IntegrationTest

  include ResponseHelper

  def setup
    @user = create(:user)
    create(:epoch_wall_clock, epoch: 101)
    create(:epoch_wall_clock, epoch: 100)
    create(:epoch_wall_clock, epoch: 102)
  end

  test 'request without token should get error' do
    get api_v1_epoch_index_url(network: 'testnet')
    assert_response 401
    expected_response = { 'error' => 'Unauthorized' }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test 'request with token should succeed' do
    get api_v1_epoch_index_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    assert_response 200
  end

  test 'request with invalid per attr should return error' do
    get api_v1_epoch_index_url(network: 'testnet', per: 501), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 400
    assert_equal 'maximum value for per is 500', resp['status']
  end

  test 'get all epochs by network success' do
    get api_v1_epoch_index_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 3, resp['epochs'].count
    assert_equal %w[
      epoch
      starting_slot
      slots_in_epoch
      network
      created_at
    ].sort, resp['epochs'][0].keys.sort
  end

  test 'epoch with default pagination returns correct number of records' do
    51.times do |i|
      create(:epoch_wall_clock, epoch: i)
    end

    get api_v1_epoch_index_url(network: 'testnet'), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 25, resp['epochs'].count
    assert_equal 54, resp['epochs_count']
  end

  test 'epoch with custom pagination returns correct number of records' do
    41.times do |i|
      create(:epoch_wall_clock, epoch: i)
    end

    get api_v1_epoch_index_url(network: 'testnet', per: 20, page: 2), headers: { 'Token' => @user.api_token }
    resp = response_to_json(@response.body)

    assert_response 200
    assert_equal 20, resp['epochs'].count
    assert_equal 23, resp['epochs'].first['epoch']
    assert_equal 44, resp['epochs_count']
  end

  test "request csv with token should succeed" do
    path = api_v1_epoch_index_url(network: "testnet") + ".csv"
    get path, headers: { "Token" => @user.api_token }
    
    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 4

    headers = EpochWallClock::API_FIELDS.map(&:to_s)
    assert_equal csv.first, headers
  end
end
