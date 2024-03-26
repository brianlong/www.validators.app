# frozen_string_literal: true

require 'test_helper'

class AsnControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data_center = create(:data_center, :berlin)
    data_center_host = create(:data_center_host, data_center: @data_center)
    validator = create(:validator)
    @validator_ip = create(:validator_ip, :active, validator: validator, data_center_host: data_center_host)

    vs = create(:validator_score_v1, validator: validator, network: "testnet")
  end

  test 'should get show with autonomous_system_number that exists and has at least one score' do
    get asn_url(network: 'testnet', asn: @data_center.traits_autonomous_system_number)
    assert_response :success
  end

  test 'show should return error with autonomous_system_number that does not exist ' do
    get asn_url(network: 'testnet', asn: 1)
    assert_response :not_found
  end
end
