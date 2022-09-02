require "test_helper"

class DataCenterStatTest < ActiveSupport::TestCase
  test "relationship belongs_to data_center returns data_center" do
    data_center = create(:data_center)
    stat = create(:data_center_stat, data_center: data_center)

    assert_equal data_center, stat.data_center
  end
end
