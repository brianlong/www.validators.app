# frozen_string_literal: true

require 'test_helper'

# SolanaLogicTest
class PipelineLogicTest < ActiveSupport::TestCase
  include PipelineLogic

  test 'array_average' do
    assert_equal 3, array_average([1, 2, 3, 4, 5])
    assert_equal 3.5, array_average([1, 2, 3, 4, 5, 6])
  end

  test 'array_median' do
    assert_equal 3, array_median([1, 2, 3, 4, 5])
    assert_equal 3.5, array_median([1, 2, 3, 4, 5, 6])
  end
end
