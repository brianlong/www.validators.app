# frozen_string_literal: true

require "test_helper"

module Blockchain
  class Base58Test < ActiveSupport::TestCase
    test ".decode decodes base58 strings into bytes" do
      assert_equal "hello world".b, Blockchain::Base58.decode("StV1DL6CwTryKyV")
    end

    test ".decode keeps leading zero bytes" do
      assert_equal "\x00\x00\x01".b, Blockchain::Base58.decode("112")
    end

    test ".decode decodes a 32 byte public key" do
      assert_equal "\x00".b * 32, Blockchain::Base58.decode("11111111111111111111111111111111")
    end
  end
end
