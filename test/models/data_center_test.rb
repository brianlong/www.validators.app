# frozen_string_literal: true

require "test_helper"

class DataCenterTest < ActiveSupport::TestCase
  def setup
    @data_center = build(:data_center, :berlin)
  end

  test "relationships data_center_hosts returns assigned data_center_hosts" do
    @data_center.save

    dch = create(:data_center_host, data_center: @data_center)
    dch2 = create(:data_center_host, data_center: @data_center)

    assert_equal 2, @data_center.data_center_hosts.size
    assert_includes @data_center.data_center_hosts, dch
    assert_includes @data_center.data_center_hosts, dch2
  end

  test "relationships validator_ips returns validator_ips through data_center_hosts" do
    @data_center.save

    validator = create(:validator)
    dch = create(:data_center_host, data_center: @data_center)
    vip = create(:validator_ip, data_center_host: dch, validator: validator)
    vip2 = create(:validator_ip, data_center_host: dch, validator: validator, address: "0.0.0.0")

    assert_equal 2, @data_center.validator_ips.size
    assert_includes @data_center.validator_ips, vip
    assert_includes @data_center.validator_ips, vip2
  end

  test "#to_builder returns correct data" do
    assert_equal "{\"autonomous_system_number\":12345}", @data_center.to_builder.target!
  end

  test "before_save #assign_data_center_key assigns key correctly" do
    @data_center.save
    assert_equal "12345-DE-Berlin", @data_center.data_center_key
  end
end
