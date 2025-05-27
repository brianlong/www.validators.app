# frozen_string_literal: true

require "test_helper"

class AppendDataCentersGeoDataTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @namespace = File.join("scripts", "data_centers_scripts", "append_data_centers_geo_data_test")
  end

  test "script creates data centers and hosts for active validator_ips" do
    val_ip = create(:validator_ip, :active, address: "192.69.220.150")

    assert_difference ["DataCenter.count", "DataCenterHost.count"], 1 do
      vcr_cassette(@namespace, __method__) do
        run_script
      end
    end

    assert_not_nil val_ip.reload.data_center_host
  end

  test "script ignores inactive or muted validator_ips" do
    val_ip_1 = create(:validator_ip, :muted, address: "160.202.128.175")
    val_ip_2 = create(:validator_ip, is_active: false, address: "103.50.32.104")

    assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
      vcr_cassette(@namespace, __method__) do
        run_script
      end
    end

    assert_nil val_ip_1.reload.data_center_host
    assert_nil val_ip_2.reload.data_center_host
  end

  def run_script
    load(Rails.root.join("script", "data_centers_scripts", "append_data_centers_geo_data.rb"))
  end
end
