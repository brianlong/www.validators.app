# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper

  test "#lamports_as_formatted_sol returns formatted sol with delimiters" do
    assert_equal "12,341.23", lamports_as_formatted_sol(12341232212414)
  end

  test "#lamports_as_formatted_sol returns 0.00 when argument is no numeric" do
    assert_equal "0.00", lamports_as_formatted_sol(nil)
    assert_equal "0.00", lamports_as_formatted_sol(false)
    assert_equal "0.00", lamports_as_formatted_sol("string")
    assert_equal "0.00", lamports_as_formatted_sol("")
    assert_equal "0.00", lamports_as_formatted_sol([])
  end
end
