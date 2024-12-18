# frozen_string_literal: true

require "test_helper"
require 'rack/cors'
require 'rack/test'

module Api
  module V1
    class PingTimesControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper

      def setup
        @user = create(:user)
      end

      test 'POST api_v1_collector without token should get error' do
        post api_v1_collector_url, params: {}
        assert_response 401
        expected_response = { 'error' => 'Unauthorized' }
        assert_equal expected_response, response_to_json(@response.body)
      end

      test 'POST api_v1_collector with empty params should get error' do
        expected_response = { 'status' => 'Bad Request' }
        # Completely empty params
        post api_v1_collector_url,
              headers: { 'Token' => @user.api_token },
              params: {}
        assert_response 400
        assert_equal expected_response, response_to_json(@response.body)
      end

      test 'POST api_v1_collector with invalid params should get error' do
        post api_v1_collector_url,
              headers: { 'Token' => @user.api_token },
              params: { collector: { one: 1, two: 2, three: 3 } }
        assert_response 400
        expected_response = { 'status' => 'Bad Request' }
        assert_equal expected_response, response_to_json(@response.body)
      end

      test 'POST api_v1_collector with valid data should succeed' do
        # Prepare the payload
        valid_payload = {
          payload_type: 'ping',
          payload_version: 1,
          payload: { 'test_key' => 'test_value' }
        }
        # Post the payload
        assert_difference("Collector.count") do
          post api_v1_collector_url,
                headers: { 'Token' => @user.api_token },
                params: valid_payload
          assert_response 202
          json = response_to_json(@response.body)
          assert_equal 'Accepted', json['status']
        end

        # Verify that the record was saved successfully
        collector = Collector.last
        assert_equal 'ping', collector.payload_type
        assert_equal 1, collector.payload_version
        assert_equal '{"test_key":"test_value"}', collector.payload
      end
    end
  end
end
