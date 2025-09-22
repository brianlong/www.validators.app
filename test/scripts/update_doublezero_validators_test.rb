# frozen_string_literal: true

require "test_helper"

class UpdateDoublezeroValidatorsTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"

    @validator = create(:validator, network: @network)
    create(:validator_ip, validator: @validator, is_active: true, address: '3.65.206.72')

    @validator1 = create(:validator, network: @network, account: 'NLMSHTjmSiRxGJPs3uaqtsFBC2dTGYwK41U18Nmw5kH')

    @validator2 = create(:validator, network: @network)
    create(:validator_ip, validator: @validator, is_active: true, address: '111.111.111.111')

    @validator3 = create(:validator, network: @network, is_dz: true)
    create(:validator_ip, validator: @validator, is_active: true, address: '123.123.123.123')

    @validator4 = create(:validator, network: @network)
    create(:validator_ip, validator: @validator4, is_active: true, address: '155.138.217.197')
  end

  test "script updates correct validators" do
    VCR.use_cassette("update_doublezero_validators") do
      load(Rails.root.join("script", "update_doublezero_validators.rb"))

      assert @validator.reload.is_dz
      assert @validator1.reload.is_dz
      refute @validator2.reload.is_dz
      refute @validator3.reload.is_dz
      assert @validator4.reload.is_dz
    end
  end
end
