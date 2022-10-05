# frozen_string_literal: true

require "test_helper"

class DataCenterHostTest < ActiveSupport::TestCase
  def setup
    @data_center = create(:data_center)
    @data_center_host = create(:data_center_host, data_center_id: @data_center.id)
    @validator = create(:validator, :with_score)
    @validator_ip = create(:validator_ip, validator: @validator, data_center_host: @data_center_host)
  end

  test "relationship belongs_to data_center returns correct data center" do
    assert @data_center_host.valid?
    assert_equal @data_center, @data_center_host.data_center
  end

  test "relationship belongs_to data_center_for_api returns data_center specified fields" do
    assert @data_center_host.valid?
    assert_equal @data_center, @data_center_host.data_center_for_api
    assert_equal DataCenter::FIELDS_FOR_API.map(&:to_s), 
                 @data_center_host.data_center_for_api.attributes.keys.sort
  end

  test "relationship belongs_to data_center is not valid when data_center is empty" do
    @data_center_host.data_center = nil

    refute @data_center_host.valid?
  end

  test "relationship has_many validator_ips returns collection of validator_ips" do
    vip1 = @validator_ip.dup
    vip2 = @validator_ip.dup

    vip1.assign_attributes(address: "192.168.0.1", data_center_host_id: @data_center_host.id)
    vip2.assign_attributes(address: "192.168.0.2", data_center_host_id: @data_center_host.id)

    vip1.save
    vip2.save

    assert_equal 3, @data_center_host.validator_ips.size
    assert_includes @data_center_host.validator_ips, vip1
    assert_includes @data_center_host.validator_ips, vip2
  end

  test "relationship has_many validator_ips_active returns collection of active validator_ips" do
    vip1 = @validator_ip.dup
    vip2 = @validator_ip.dup

    vip1.assign_attributes(
      address: "192.168.0.1",
      data_center_host_id: @data_center_host.id,
    )

    vip2.assign_attributes(
      address: "192.168.0.2",
      data_center_host_id: @data_center_host.id,
      is_active: true
    )

    vip1.save
    vip2.save

    assert_equal 1, @data_center_host.validator_ips_active.size
    assert_includes @data_center_host.validator_ips_active, vip2
  end

  test "relationship has_many validators" \
       "returns collection of validators with active validator_ip" do
    vip1 = @validator_ip.dup
    vip2 = @validator_ip.dup
    vip3 = @validator_ip.dup

    validator2 = create(:validator)
    validator_with_inactive_ip = create(:validator)

    vip1.assign_attributes(
      address: "192.168.0.1", 
      data_center_host_id: @data_center_host.id,
      validator_id: validator_with_inactive_ip.id
    )

    vip2.assign_attributes(
      address: "192.168.0.2", 
      data_center_host_id: @data_center_host.id,
      is_active: true
    )

    vip3.assign_attributes(
      address: "192.168.0.2", 
      data_center_host_id: @data_center_host.id,
      is_active: true,
      validator_id: validator2.id
    )

    vip1.save 
    vip2.save
    vip3.save

    assert_equal 2, @data_center_host.validators.size
    assert_includes @data_center_host.validators, @validator
    assert_includes @data_center_host.validators, validator2
  end

  test "relationship has_many validator_score_v1s" \
       "returns collection of validator's scores with active validator_ip" do
    vip1 = @validator_ip.dup
    vip2 = @validator_ip.dup
    vip3 = @validator_ip.dup

    validator2 = create(:validator, :with_score)
    validator_with_inactive_ip = create(:validator, :with_score)

    vip1.assign_attributes(
      address: "192.168.0.1", 
      data_center_host_id: @data_center_host.id,
      validator_id: validator_with_inactive_ip.id
    )

    vip2.assign_attributes(
      address: "192.168.0.2", 
      data_center_host_id: @data_center_host.id,
      is_active: true
    )

    vip3.assign_attributes(
      address: "192.168.0.2", 
      data_center_host_id: @data_center_host.id,
      is_active: true,
      validator_id: validator2.id
    )

    vip1.save 
    vip2.save
    vip3.save

    assert_equal 2, @data_center_host.validator_score_v1s.size
    assert_includes @data_center_host.validator_score_v1s, @validator.validator_score_v1
    assert_includes @data_center_host.validator_score_v1s, validator2.validator_score_v1
  end

  test "relationship has_many gossip_nodes returns correct nodes" do
    @validator_ip.update(is_active: true)
    node = create(:gossip_node, ip: @validator_ip.address)

    assert_equal node, @data_center_host.gossip_nodes.first
  end

  test "scope for_api returs data_center_host specified fields" do
    assert_equal DataCenterHost::FIELDS_FOR_API.map(&:to_s), 
                 DataCenterHost.for_api.first.attributes.keys.sort
  end
end
