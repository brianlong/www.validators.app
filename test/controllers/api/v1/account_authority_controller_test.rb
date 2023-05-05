# write tests for AccountAuthorityController#index
# test/controllers/api/v1/account_authority_controller_test.rb
# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AccountAuthorityControllerTest < ActionDispatch::IntegrationTest
      setup do
        @validator = create(:validator, account: 'test_account_1')
        5.times do
          create(:account_authority_history)
        end
      end

      test 'should get index' do
        get api_v1_account_authority_index_url
        assert_response :success
      end

      test 'should get index with validator' do
        get api_v1_account_authority_index_url(validator: 'test')
        assert_response :success
      end
    end
  end
end
