# frozen_string_literal: true

require "test_helper"

class AddValidatorIdToValidatorHistoriesTest < ActiveSupport::TestCase
  test "script ignores validator histories that validator not exists" do
    vh = create(:validator_history, validator_id: nil)

    load(Rails.root.join("script", "one_time_scripts", "add_validator_id_to_validator_histories.rb"))
    
    assert_nil vh.validator_id
  end

  test "script adds an association to validator_histories that validator persists" do
    validator = create(:validator, account: "test_account")
    vhs = create_list(:validator_history,
                      10,
                      account: "test_account",
                      validator_id: nil)

    load(Rails.root.join("script", "one_time_scripts", "add_validator_id_to_validator_histories.rb"))

    assert vhs.map(&:validator_id).uniq, [validator.id]
  end
end
