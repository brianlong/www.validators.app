require 'test_helper'

class ValidatorIpTest < ActiveSupport::TestCase
  def setup
    @validator = create(:validator)
    @data_center = create(:data_center)
    @data_center_host = create(:data_center_host, data_center_id: @data_center.id)
    @vip = build(:validator_ip, validator: @validator, data_center_host_id: @data_center_host.id)
  end

  test "#relationships belongs_to validator corectly asssigns validator" do
    assert @vip.valid?
    assert_equal @validator, @vip.validator
  end

  test "#relationships belongs_to validator without validator is invalid" do
    @vip.validator = nil
    refute @vip.valid?
  end

  test "#relationships belongs_to data_center_host corectly asssigns data_center_host" do
    assert @vip.valid?
    assert_equal @data_center_host, @vip.data_center_host
  end

  test "#relationships belongs_to data_center_host is optionally" do
    @vip.data_center_host_id = nil
    assert @vip.valid?
  end

  test "#relationships has_one data_center returns data_center" do
    assert_equal @data_center, @vip.data_center
  end
end
