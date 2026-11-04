# frozen_string_literal: true

require "test_helper"

module Blockchain
  class SignerStoreTest < ActiveSupport::TestCase
    test ".decode decodes base2 bitmap" do
      bytes = [0, 10].pack("CS<") + [0b0000_0101, 0b0000_0010].pack("C*")

      assert_equal({ bitmap_length: 10, ranks: [0, 2, 9] }, Blockchain::SignerStore.decode(bytes))
    end

    test ".decode decodes base3 bitmap into base and fallback ranks" do
      bytes = [1, 5].pack("CS<") + [1 + 2 * 3 + 0 * 9 + 1 * 27 + 2 * 81].pack("C")

      result = Blockchain::SignerStore.decode(bytes)

      assert_equal [0, 3], result[:ranks]
      assert_equal [1, 4], result[:fallback_ranks]
    end

    test ".validate! returns bytes for valid bitmap" do
      bytes = [0, 8].pack("CS<") + [255].pack("C")

      assert_equal bytes, Blockchain::SignerStore.validate!(bytes)
    end

    test ".decode raises for invalid input" do
      [
        nil,
        "\x00".b,
        [2, 8].pack("CS<") + "\x00".b,
        [0, 16].pack("CS<") + "\x00".b,
        [1, 10].pack("CS<") + "\x00".b
      ].each do |bytes|
        assert_raises(Blockchain::SignerStore::DecodeError) { Blockchain::SignerStore.decode(bytes) }
      end
    end
  end
end
