require 'test_helper'

class IpTest < ActiveSupport::TestCase
  test 'relationship belongs_to :validator_score_v1' do
    address = '192.123.23.2'
    validator = create(:validator)
    score = create(
      :validator_score_v1,
      validator: validator, 
      ip_address: address
    )
    ip = create(:ip, address: address)

    assert_equal score, ip.validator_score_v1
  end
end
