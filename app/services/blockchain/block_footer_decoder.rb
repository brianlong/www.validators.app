# frozen_string_literal: true

module Blockchain
  class BlockFooterDecoder
    class DecodeError < StandardError; end

    BLS_SIGNATURE_SIZE = 96
    HASH_SIZE = 32

    def initialize(footer)
      @footer = footer
    end

    def call
      {
        slot: @footer.slot,
        bank_id: @footer.bank_id,
        bank_hash: @footer.bank_hash.b,
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
      final_signature, final_signers = read_votes_aggregate(reader)
      notar_signature, notar_signers = reader.u8 == 1 ? read_votes_aggregate(reader) : [nil, nil]
      reader.ensure_consumed!

      {
        slot: slot,
        block_id: block_id,
        finalization: notar_signers ? "slow" : "fast",
        final_signature: final_signature,
        final_signers: final_signers,
        notar_signature: notar_signature,
        notar_signers: notar_signers
      }
    end

    def decode_notar_reward_cert(bytes)
      reader = ByteReader.new(bytes)
      slot = reader.u64
      block_id = reader.read_hash
      signature = reader.take(BLS_SIGNATURE_SIZE)
      signers = validated_signers(reader.take(reader.short_u16))
      reader.ensure_consumed!

      { slot: slot, block_id: block_id, signature: signature, signers: signers }
    end

    def decode_skip_reward_cert(bytes)
      reader = ByteReader.new(bytes)
      slot = reader.u64
      signature = reader.take(BLS_SIGNATURE_SIZE)
      signers = validated_signers(reader.take(reader.short_u16))
      reader.ensure_consumed!

      { slot: slot, signature: signature, signers: signers }
    end

    def read_votes_aggregate(reader)
      signature = reader.take(BLS_SIGNATURE_SIZE)
      [signature, validated_signers(reader.take(reader.u16))]
    end

    def validated_signers(bytes)
      Blockchain::SignerStore.validate!(bytes)
    rescue Blockchain::SignerStore::DecodeError => e
      raise DecodeError, e.message
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
