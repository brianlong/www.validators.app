# frozen_string_literal: true

FactoryBot.define do
  factory :mainnet_block, class: Blockchain::MainnetBlock do
    height { "123" }
    block_time { 12 }
    blockhash { "block_hash_123" }
    parent_slot { 12345 }
    slot_number { 12346 }
  end

  factory :testnet_block, class: Blockchain::TestnetBlock do
    height { "123" }
    block_time { 12 }
    blockhash { "block_hash_123" }
    parent_slot { 12345 }
    slot_number { 12346 }
  end

  factory :pythnet_block, class: Blockchain::PythnetBlock do
    height { "123" }
    block_time { 12 }
    blockhash { "block_hash_123" }
    parent_slot { 12345 }
    slot_number { 12346 }
  end
end
