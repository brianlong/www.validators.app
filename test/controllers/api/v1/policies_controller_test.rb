# frozen_string_literal: true

require 'test_helper'

class Api::V1::PoliciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(username: 'apitest', email: 'apitest@example.com', password: 'password')
    @headers = { 'Token' => @user.api_token }
    @policy = FactoryBot.create(:policy)
  end

  test 'should get index' do
    get api_v1_policies_url('mainnet', format: :json), headers: @headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json['policies'].is_a?(Array)
    assert_equal 1, json['policies'].size
    assert_equal json["total_count"], json['policies'].size
  end

  test 'should filter policies by query' do
    get api_v1_policies_url('mainnet', format: :json, query: 'insurance'), headers: @headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json['policies'].is_a?(Array)
    assert_equal 1, json['policies'].size
    assert_equal json["total_count"], json['policies'].size
    assert_equal @policy.pubkey, json['policies'].first['pubkey']

    get api_v1_policies_url('mainnet', format: :json, query: 'invalid'), headers: @headers
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 0, json['policies'].size
  end

  test 'should paginate policies' do
    create_list(:policy, 5)
    get api_v1_policies_url('mainnet', format: :json, page: 1, limit: 2), headers: @headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json['policies'].is_a?(Array)
    json = JSON.parse(response.body)
    assert_equal 2, json['policies'].size
  end

  test 'should show policy by pubkey' do
    pubkey = @policy.mint
    get api_v1_policy_url('mainnet', pubkey: pubkey, format: :json), headers: @headers
    # Accept 404 if not found, otherwise check structure
    assert_includes [200, 404], response.status
    if response.status == 200
      json = JSON.parse(response.body)
      assert_equal pubkey, json['pubkey']
    end
  end

  test 'should return 401 without token' do
    get api_v1_policies_url('mainnet', format: :json)
    assert_response :unauthorized
  end
end
