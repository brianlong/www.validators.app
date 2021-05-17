# frozen_string_literal: true

require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test 'encode_utf_8 properly encode string with unusual characters' do
    assert_equal 'Staking-P◎◎l FREE Validati◎n',
                 'Staking-P◎◎l FREE Validati◎n'.encode_utf_8
  end
end
