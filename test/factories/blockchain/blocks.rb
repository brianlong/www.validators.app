FactoryBot.define do
  factory :blockchain_block, class: 'Blockchain::Block' do
    height { "" }
    block_time { "" }
    hash { "MyString" }
    parent_slot { "" }
  end
end
