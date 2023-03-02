# frozen_string_literal: true

require "test_helper"

class UpdateJitoValidatorsTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"
    @validator = create(:validator, network: @network)
    create(:vote_account,
           account: "E3yhPs5PPN4RZh8FbJo2eqtdrAYKCK9H7pcSD1vCNCP4",
           validator: @validator, is_active: true)
  end

  test "script updates correct validators" do
    VCR.use_cassette("update_jito_validators") do
      load(Rails.root.join("script", "update_jito_validators.rb"))

      assert @validator.reload.jito_collaboration
    end
  end

  test "script does not update inactive vote_accounts" do
    @validator.vote_accounts.update_all(is_active: false)
    VCR.use_cassette("update_jito_validators") do
      load(Rails.root.join("script", "update_jito_validators.rb"))
      refute @validator.reload.jito_collaboration
    end
  end
end
