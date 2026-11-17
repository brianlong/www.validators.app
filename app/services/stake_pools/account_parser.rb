# frozen_string_literal: true

module StakePools
  class AccountParser
    class InvalidAccount < StandardError; end

    STAKE_POOL_ACCOUNT_TYPE = 1
    PUBKEY_SIZE = 32
    PUBKEYS_BEFORE_BUMP_SEED = 3
    PUBKEYS_AFTER_BUMP_SEED = 5
    LOCKUP_SIZE = 8 + 8 + PUBKEY_SIZE

    def initialize(base64_data)
      @data = Base64.decode64(base64_data.to_s)
      @offset = 0
    end

    def call
      raise InvalidAccount, "Not a stake pool account" unless read_u8 == STAKE_POOL_ACCOUNT_TYPE

      skip(PUBKEYS_BEFORE_BUMP_SEED * PUBKEY_SIZE + 1 + PUBKEYS_AFTER_BUMP_SEED * PUBKEY_SIZE)
      total_lamports = read_u64
      pool_token_supply = read_u64
      skip(8 + LOCKUP_SIZE)

      manager_fee = read_fee
      next_manager_fee = read_future_fee
      skip_optional_pubkey
      skip_optional_pubkey
      skip(16 + 16)
      read_future_fee
      skip(1)
      skip_optional_pubkey
      deposit_fee = read_fee
      skip(1)
      skip_optional_pubkey
      withdrawal_fee = read_fee
      next_withdrawal_fee = read_future_fee

      {
        total_lamports: total_lamports,
        pool_token_supply: pool_token_supply,
        manager_fee: manager_fee,
        next_manager_fee: next_manager_fee,
        deposit_fee: deposit_fee,
        withdrawal_fee: withdrawal_fee,
        next_withdrawal_fee: next_withdrawal_fee
      }
    end

    private

    def read(size)
      raise InvalidAccount, "Unexpected end of account data" if @offset + size > @data.bytesize

      bytes = @data.byteslice(@offset, size)
      @offset += size
      bytes
    end

    def skip(size)
      read(size)
    end

    def read_u8
      read(1).unpack1("C")
    end

    def read_u64
      read(8).unpack1("Q<")
    end

    def read_fee
      denominator = read_u64
      numerator = read_u64
      return 0.0 if denominator.zero?

      (numerator.to_f / denominator * 100).round(4)
    end

    def read_future_fee
      read_u8.zero? ? nil : read_fee
    end

    def skip_optional_pubkey
      skip(PUBKEY_SIZE) unless read_u8.zero?
    end
  end
end
