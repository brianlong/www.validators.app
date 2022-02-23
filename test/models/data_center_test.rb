# frozen_string_literal: true

require "test_helper"

class DataCenterTest < ActiveSupport::TestCase
  def setup
    @data_center = build(:data_center, :berlin)
  end

  test "#to_builder returns correct data" do
    assert_equal "{\"autonomous_system_number\":54321}", @data_center.to_builder.target!
  end

  test "before_save #assign_data_center_key assigns key correctly" do
    @data_center.save
    assert_equal "54321-DE-Europe/CET", @data_center.data_center_key
  end
end
