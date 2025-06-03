# frozen_string_literal: true

require "test_helper"

class UpdateDoublezeroValidatorsTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"
    @validator = create(:validator, network: @network)
    create(:validator_ip, validator: @validator, is_active: true, address: '144.168.36.130')

    @validator2 = create(:validator, network: @network)
    create(:validator_ip, validator: @validator, is_active: true, address: '123.123.123.123')
  end

  test "script updates correct validators" do
    VCR.use_cassette("update_doublezero_validators") do
      load(Rails.root.join("script", "update_doublezero_validators.rb"))

      assert @validator.reload.is_dz
      refute @validator2.reload.is_dz
    end
  end
end
