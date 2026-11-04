# frozen_string_literal: true

module Blockchain
  module Base58
    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    module_function

    def decode(value)
      number = value.each_char.inject(0) { |acc, char| acc * 58 + ALPHABET.index(char) }
      hex = number.zero? ? "" : number.to_s(16)
      hex = "0#{hex}" if hex.size.odd?
      ("\x00" * value[/\A1*/].size).b + [hex].pack("H*")
    end
  end
end
