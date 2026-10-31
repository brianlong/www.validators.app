# frozen_string_literal: true

module Blockchain
  module SignerStore
    class DecodeError < StandardError; end

    BASE2 = 0
    BASE3 = 1
    BASE3_SYMBOLS_PER_BYTE = 5
    HEADER_SIZE = 3

    module_function

    def decode(bytes)
      version, bits, data = parse(bytes)

      case version
      when BASE2 then decode_base2(data.bytes, bits)
      when BASE3 then decode_base3(data.bytes, bits)
      end
    end

    def validate!(bytes)
      parse(bytes)
      bytes
    end

    def parse(bytes)
      raise DecodeError, "signer store too short" if bytes.nil? || bytes.bytesize < HEADER_SIZE

      version = bytes.getbyte(0)
      bits = bytes.byteslice(1, 2).unpack1("S<")
      data = bytes.byteslice(HEADER_SIZE..)
      expected_size = payload_size(version, bits)
      raise DecodeError, "invalid payload size for version #{version}" unless data.bytesize == expected_size

      [version, bits, data]
    end

    def payload_size(version, bits)
      case version
      when BASE2 then (bits + 7) / 8
      when BASE3 then (bits + BASE3_SYMBOLS_PER_BYTE - 1) / BASE3_SYMBOLS_PER_BYTE
      else raise DecodeError, "unknown signer store version #{version}"
      end
    end

    def decode_base2(data, bits)
      { bitmap_length: bits, ranks: (0...bits).select { |i| data[i / 8][i % 8] == 1 } }
    end

    def decode_base3(data, bits)
      ranks = []
      fallback_ranks = []
      data.each_with_index do |byte, chunk_index|
        first = chunk_index * BASE3_SYMBOLS_PER_BYTE
        (first...[first + BASE3_SYMBOLS_PER_BYTE, bits].min).each do |i|
          case byte % 3
          when 1 then ranks << i
          when 2 then fallback_ranks << i
          end
          byte /= 3
        end
      end
      { bitmap_length: bits, ranks: ranks, fallback_ranks: fallback_ranks }
    end

    private_class_method :parse, :payload_size, :decode_base2, :decode_base3
  end
end
