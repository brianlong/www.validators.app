# frozen_string_literal: true

require 'test_helper'

class ArrayTest < ActiveSupport::TestCase
  test 'average' do
    assert_equal 5.0, [1, 2, 3, 4, 5, 6, 7, 8, 9].average
    assert_equal 5.0, [5, 4, 1, 6, 7, 8, 9, 3, 2].average
  end

  test 'median' do
    assert_equal 2, [1, 1, 1, 1, 2, 3, 4, 5, 9].median
    assert_equal 2, [1, 2, 3, 6, 1, 1, 1, 2, 4].median
    assert_equal 2, [1, 1, 1, 1, 2, 3, 4, 5].median
    assert_equal 2, [1, 2, 3, 1, 4, 1, 1, 5].median
  end

  test 'guard' do
    assert_raise do
      %w[a b c].average
    end

    assert_raise do
      %i[a b c].average
    end

    assert_nothing_raised do
      [1, 3, 3.0, 5.0, 1e34].average
    end
  end
end
