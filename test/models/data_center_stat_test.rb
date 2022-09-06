# frozen_string_literal: true

require "test_helper"

class DataCenterStatTest < ActiveSupport::TestCase
  setup do
    @data_center = create(:data_center)
  end

  test "relationship belongs_to data_center returns data_center" do
    data_center = create(:data_center)
    stat = create(:data_center_stat, data_center: @data_center)

    assert_equal @data_center, stat.data_center
  end

  test "validates_uniqueness_of data_center returns error while creating similar records" do
    network = "testnet"

    create(:data_center_stat, data_center: @data_center, network: network)

    assert_raises ActiveRecord::RecordInvalid do 
      create(:data_center_stat, data_center: @data_center, network: network)
    end
  end
end
