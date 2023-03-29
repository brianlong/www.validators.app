# frozen_string_literal: true

require 'test_helper'

class ValidatorsHelperTest < ActiveSupport::TestCase
  include ValidatorsHelper
  def setup
    @versions_array = [
      {"1.6.16"=>{"count"=>2, "stake_percent"=>0.0}},
      {"1.6.18"=>{"count"=>3, "stake_percent"=>0.0}},
      {"1.6.9"=>{"count"=>4, "stake_percent"=>0.0}},
      {"1.7.0"=>{"count"=>8, "stake_percent"=>0.0}},
      {"1.7.1"=>{"count"=>9, "stake_percent"=>0.0}},
      {"1.7.2"=>{"count"=>1, "stake_percent"=>0.0}},
      {"1.7.3"=>{"count"=>36, "stake_percent"=>1.05}},
      {"1.7.4"=>{"count"=>129, "stake_percent"=>7.39}},
      {"1.7.5"=>{"count"=>84, "stake_percent"=>4.2}},
      {"1.7.6"=>{"count"=>1697, "stake_percent"=>86.25}},
      {"1.7.7"=>{"count"=>5, "stake_percent"=>0.81}},
      {"1.8.0"=>{"count"=>2, "stake_percent"=>0.0}}
    ]
  end

  test '#sort_software_versions sort versions in correct order' do
    expected_order = [
      "1.7.6",
      "1.7.4",
      "1.7.5",
      "1.7.3",
      "1.7.7",
      "1.8.0",
      "1.7.2",
      "1.7.1",
      "1.7.0",
      "1.6.9",
      "1.6.18",
      "1.6.16"
    ]

    sorted_versions = sort_software_versions(@versions_array)
    assert_equal expected_order, sorted_versions.map{ |e| e.keys }.flatten
  end

  test "#displayed_validator_name returns correct string" do
    validator = build(:validator,
                      account: "DDnAqxJVFo2GVTujibHt5cjevHMSE9bo8HJaydHoshdp",
                      name: nil)

    assert_equal "DDnAqx...shdp", displayed_validator_name(validator), "identity should be shortened"

    validator = build(:validator,
                      account: "DDnAqxJVFo2GVTujibHt5cjevHMSE9bo8HJaydHoshdp",
                      name: "DDnAqxJVFo2GVTujibHt5cjevHMSE9bo8HJaydHoshdp")

    assert_equal "DDnAqx...shdp", displayed_validator_name(validator), "name the same as account should be shortened"

    validator = build(:validator,
                      account: "DDnAqxJVFo2GVTujibHt5cjevHMSE9bo8HJaydHoshdp",
                      name: "Block Logic")

    assert_equal "Block Logic", displayed_validator_name(validator), "name different than account should be displayed"
  end

  test "#displayed_validator_name hides name if validator is private" do
    validator = create(:validator, :private, name: "Block Logic")
    assert_equal "Private Validator", displayed_validator_name(validator), "private validator's name should be hidden"

    validator = create(:validator, :private, name: "Lido / Block Logic")
    assert_equal "Lido / Block Logic", displayed_validator_name(validator), "lido's name should not be hidden"
  end
end
