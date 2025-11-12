# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CommissionHistoriesControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper

      def setup
        @user_params = {
          username: 'test',
          email: 'test@test.com',
          password: 'password'
        }
        @user = User.create(@user_params)

        val1 = create(:validator, :with_score, account: 'acc1', network: 'testnet')
        val2 = create(:validator, :with_score, account: 'acc2', network: 'testnet')
        val3 = create(:validator, :with_score, account: 'acc3', network: 'testnet')

        create(:commission_history, validator: val1)
        create(:commission_history, validator: val2, created_at: 2.days.ago)
        create(:commission_history, validator: val3, created_at: 32.days.ago)
      end

      test 'When reaching the commission changes api \
            with correct token \
            should return 200' do
        get api_v1_commission_histories_index_path(network: 'testnet'), headers: {
          'Token' => @user.api_token
        }

        assert_response 200
      end

      test 'When reaching the commission changes api \
            with correct token and no time range\
            should return 200 and correct validators' do
        get api_v1_commission_histories_index_path(network: 'testnet'), headers: {
          'Token' => @user.api_token
        }

        assert_response 200
        json = response_to_json(@response.body)
        assert_equal 3, json['commission_histories'].size
        assert_equal 3, json['total_count']
      end

      test 'When reaching the commission changes api \
            with correct token and csv format\
            should return 200' do

        path = api_v1_commission_histories_index_path(network: "testnet") + ".csv"
        get path, headers: { "Token" => @user.api_token }

        assert_response :success
        assert_equal "text/csv", response.content_type
        csv = CSV.parse response.body # Let raise if invalid CSV
        assert csv
        assert_equal csv.size, 4  # headers + 3 records

        headers = (
          CommissionHistory::API_FIELDS +
          CommissionHistory::API_VALIDATOR_FIELDS
        ).map(&:to_s)
        assert_equal csv.first, headers
      end
    end
  end
end

