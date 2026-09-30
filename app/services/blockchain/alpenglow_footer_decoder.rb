# frozen_string_literal: true

module Blockchain
  class AlpenglowFooterDecoder
    class DecodeError < StandardError; end

    BLS_SIGNATURE_SIZE = 96
    HASH_SIZE = 32
    SIGNER_STORE_BASE2 = 0
    SIGNER_STORE_BASE3 = 1
    BASE3_SYMBOLS_PER_BYTE = 5

    def initialize(footer)
      @footer = footer
    end

    def call
      {
        slot: @footer.slot,
        bank_id: @footer.bank_id,
        bank_hash: @footer.bank_hash.unpack1("H*"),
        block_producer_time_nanos: @footer.block_producer_time_nanos,
        block_user_agent: @footer.block_user_agent.to_s.dup.force_encoding(Encoding::UTF_8).scrub,
        block_final_cert: decode_optional(@footer.block_final_cert) { |bytes| decode_block_final_cert(bytes) },
        notar_reward_cert: decode_optional(@footer.notar_reward_cert) { |bytes| decode_notar_reward_cert(bytes) },
        skip_reward_cert: decode_optional(@footer.skip_reward_cert) { |bytes| decode_skip_reward_cert(bytes) }
      }
    end

    private

    def decode_optional(bytes)
      return nil if bytes.nil? || bytes.empty?

      yield bytes.b
    end

    def decode_block_final_cert(bytes)
      reader = ByteReader.new(bytes)
      slot = reader.u64
      block_id = reader.read_hash
      final_aggregate = read_votes_aggregate(reader)
      notar_aggregate = reader.u8 == 1 ? read_votes_aggregate(reader) : nil
      reader.ensure_consumed!

      {
        slot: slot,
        block_id: block_id,
        finalization: notar_aggregate ? "slow" : "fast",
        final_aggregate: final_aggregate,
        notar_aggregate: notar_aggregate
      }
    end

    def decode_notar_reward_cert(bytes)
      reader = ByteReader.new(bytes)
      slot = reader.u64
      block_id = reader.read_hash
      reader.skip(BLS_SIGNATURE_SIZE)
      signer_data = signers(reader.take(reader.short_u16))
      reader.ensure_consumed!

      { slot: slot, block_id: block_id }.merge(signer_data)
    end

    def decode_skip_reward_cert(bytes)
      reader = ByteReader.new(bytes)
      slot = reader.u64
      reader.skip(BLS_SIGNATURE_SIZE)
      signer_data = signers(reader.take(reader.short_u16))
      reader.ensure_consumed!

      { slot: slot }.merge(signer_data)
    end

    def read_votes_aggregate(reader)
      reader.skip(BLS_SIGNATURE_SIZE)
      signers(reader.take(reader.u16))
    end

    def signers(bytes)
      self.class.decode_signers(bytes).merge(signers: bytes)
    end

    class << self
      def decode_signers(bytes)
        raise DecodeError, "signer store too short" if bytes.nil? || bytes.bytesize < 3

        version = bytes.getbyte(0)
        bits = bytes.byteslice(1, 2).unpack1("S<")
        data = bytes.byteslice(3..).bytes

        case version
        when SIGNER_STORE_BASE2 then decode_base2(data, bits)
        when SIGNER_STORE_BASE3 then decode_base3(data, bits)
        else raise DecodeError, "unknown signer store version #{version}"
        end
      end

      private

      def decode_base2(data, bits)
        raise DecodeError, "invalid base2 payload size" unless data.size == (bits + 7) / 8

        ranks = (0...bits).select { |i| data[i / 8][i % 8] == 1 }
        { bitmap_length: bits, ranks: ranks }
      end

      def decode_base3(data, bits)
        expected_size = (bits + BASE3_SYMBOLS_PER_BYTE - 1) / BASE3_SYMBOLS_PER_BYTE
        raise DecodeError, "invalid base3 payload size" unless data.size == expected_size

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
    end

    class ByteReader
      def initialize(bytes)
        @bytes = bytes
        @offset = 0
      end

      def take(size)
        if @offset + size > @bytes.bytesize
          raise DecodeError, "unexpected end of data at #{@offset} (need #{size}, have #{@bytes.bytesize - @offset})"
        end

        chunk = @bytes.byteslice(@offset, size)
        @offset += size
        chunk
      end

      def skip(size)
        take(size)
        nil
      end

      def u8
        take(1).unpack1("C")
      end

      def u16
        take(2).unpack1("S<")
      end

      def u64
        take(8).unpack1("Q<")
      end

      def read_hash
        take(HASH_SIZE).unpack1("H*")
      end

      def short_u16
        value = 0
        3.times do |i|
          byte = u8
          value |= (byte & 0x7f) << (7 * i)
          return value if (byte & 0x80).zero?
        end
        raise DecodeError, "invalid short_u16"
      end

      def ensure_consumed!
        remaining = @bytes.bytesize - @offset
        raise DecodeError, "#{remaining} trailing bytes" unless remaining.zero?
      end
    end
  end
end
