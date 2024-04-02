FactoryBot.define do
  factory :blockchain_block, class: 'Blockchain::Block' do
    height { "123" }
    block_time { 12 }
    blockhash { "block_hash_123" }
    parent_slot { 12345 }
    slot_number { 12346 }
  end
end
