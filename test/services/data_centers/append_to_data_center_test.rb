# frozen_string_literal: true

require "test_helper"

module DataCenters
  class AppendToDataCenterTest < ActiveSupport::TestCase
    setup do
      @data_center = create(
        :data_center,
        :netherlands
      )
      create(:data_center_host, data_center: @data_center)
      @validator = create(:validator)
      
      @service = AppendToDataCenter.new(@data_center)
    end

    test ".call when validator has active ip appends validator to data_center " do
      validator_ip = create(
        :validator_ip,
        :active,
        validator: @validator
      )

      @service.call(@validator)

      assert_equal @validator.data_center, @data_center
      assert_equal @validator.validator_ip_active, validator_ip
    end

    test ".call when validator does not have active ip appends validator to data_center" do
      @service.call(@validator)

      assert_equal @validator.data_center, @data_center
      assert @validator.reload.validator_ip_active
    end
  end
end

