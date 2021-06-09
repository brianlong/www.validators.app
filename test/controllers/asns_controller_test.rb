require 'test_helper'

class AsnControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(
      :ip, 
      traits_autonomous_system_number: 12345, 
      data_center_key: 'data_center_key'
    )
  end

  test 'should get show with autonomous_system_number that exists ' do
    get asn_url(network: 'testnet', asn: 12345)
    assert_response :success
  end

  test 'show should return error with autonomous_system_number that does not exist ' do
    get asn_url(network: 'testnet', asn: 1)
    assert_response :not_found
  end
end
