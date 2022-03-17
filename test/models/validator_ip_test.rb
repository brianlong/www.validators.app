require 'test_helper'

class ValidatorIpTest < ActiveSupport::TestCase
  def setup
    @validator = create(:validator)
    @validator_score_v1 = create(:validator_score_v1, validator: @validator)
    @data_center = create(:data_center, :berlin)
    @data_center_host = create(:data_center_host, data_center_id: @data_center.id)
    @vip = build(:validator_ip, :active, validator: @validator, data_center_host_id: @data_center_host.id)
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

  test "#relationships belongs_to data_center_host_for_api returns specified fields" do
    assert_equal DataCenterHost::FIELDS_FOR_API.map(&:to_s), @vip.data_center_host_for_api.attributes.keys
  end

  test "callbacks #copy_data_to_score after_touch copies data_center_key from data_center to score" do
    @validator_score_v1.update(data_center_key: nil)
    assert_nil @validator_score_v1.reload.data_center_key

    @vip.save
    @vip.touch

    assert_equal @data_center.data_center_key, @validator_score_v1.reload.data_center_key
  end
  
  test "#set_is_active updates validator_ips of validator to false and set is_active on the modified one" do
    vips = create_list(
      :validator_ip,
      5,
      validator: @validator, 
      data_center_host_id: @data_center_host.id
    )

    vip_first = vips.first
    vip_last = vips.last

    vip_first.update(is_active: true)

    assert vip_first.reload.is_active
    refute vip_last.reload.is_active

    vip_last.set_is_active

    refute vip_first.reload.is_active
    assert vip_last.reload.is_active
  end

  test "scope .is_active returns only active validator ips" do
    create(:validator_ip, validator: @validator)

    active = create(:validator_ip, :active, validator: @validator)

    active_ips = ValidatorIp.active

    assert_equal 1, active_ips.size
    assert_equal active, active_ips.first
  end
end
