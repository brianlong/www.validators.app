require "test_helper"

class DataCenterHostTest < ActiveSupport::TestCase
  def setup
    @validator = create(:validator)
    @validator_ip = build(:validator_ip, validator: @validator)
    @data_center = create(:data_center)
    @data_center_host = build(:data_center_host, data_center_id: @data_center.id)
  end

  test "#relationships belongs_to data_center returns correct data center" do
    assert @data_center_host.valid?
    assert_equal @data_center, @data_center_host.data_center
  end

  test "#relationships belongs_to data_center is not valid when data_center is empty" do
    @data_center_host.data_center = nil

    refute @data_center_host.valid?
  end

  test "#relationships has_many validator_ips returns collection of validator_ips" do
    # Assigning validator_ips to data_center_host
    @data_center_host.save
    
    vip1 = @validator_ip.dup
    vip2 = @validator_ip.dup

    vip1.assign_attributes(address: "192.168.0.1", data_center_host_id: @data_center_host.id)
    vip2.assign_attributes(address: "192.168.0.2", data_center_host_id: @data_center_host.id)

    vip1.save
    vip2.save

    assert_equal 2, @data_center_host.validator_ips.size
    assert_includes @data_center_host.validator_ips, vip1
    assert_includes @data_center_host.validator_ips, vip2
  end
end
