FactoryBot.define do
  factory :account_authority_history do
    vote_account
    network { "testnet" }
    authorized_withdrawer_before { "withdrawer" }
    authorized_withdrawer_after { "newwithdrawer" }
  end
end
