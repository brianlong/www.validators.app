# frozen_string_literal: true

require 'test_helper'

# ValidatorsControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @validator = create(:validator, :with_score, network: 'testnet')
    create(:validator, :with_score, network: 'testnet')
  end

  test 'should get index' do
    get validators_url(network: 'testnet')
    assert_response :success
  end

  test 'should show validator' do
    get validator_url(network: 'testnet', account: @validator.account)
    assert_response :success
  end
end
