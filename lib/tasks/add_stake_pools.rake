# frozen_string_literal: true

@mainnet_stake_pools = [
  {
    name: "Socean",
    authority: "AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck",
    network: "mainnet",
    ticker: "scnsol"
  },
  {
    name: "Marinade",
    authority: "9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco",
    network: "mainnet",
    ticker: "msol"
  },
  {
    name: "Jpool",
    authority: "HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt",
    network: "mainnet",
    ticker: "jsol"
  },
  {
    name: "Lido",
    authority: "W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5",
    network: "mainnet",
    ticker: "stsol"
  },
  {
    name: "DAOPool",
    authority: "BbyX1GwUNsfbcoWwnkZDo8sqGmwNDzs2765RpjyQ1pQb",
    network: "mainnet",
    ticker: "daosol"
  },
  {
    name: "Eversol",
    authority: "C4NeuptywfXuyWB9A7H7g5jHVDE8L6Nj2hS53tA71KPn",
    network: "mainnet",
    ticker: "esol"  
  },
  {
    name: "BlazeStake",
    authority: "6WecYymEARvjG5ZyqkrVQ6YkhPfujNzWpSPwNKXHCbV2",
    network: "mainnet",
    ticker: "bsol"  
  },
  {
    name: "Jito",
    authority: "6iQKfEyhr3bZMotVkW6beNZz5CPAkiwvgV2CTje9pVSS",
    network: "mainnet",
    ticker: "jitosol"
  }
]

@testnet_stake_pools = [
  {
    name: "Jpool",
    authority: "25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT",
    network: "testnet",
    ticker: "jsol"
  }
]

@pythnet_stake_pools = []

@manager_fees = {
  socean: 2, #https://www.socean.fi/en/ , https://soceanfi.notion.site/FAQ-e0e2b353a44a4c11b53f614f3dc7b730
  marinade: 6, #https://docs.marinade.finance/faq/faq
  jpool: 0, #https://jpool.one/pool-info
  lido: 10, #https://solana.lido.fi/
  daopool: 2,
  eversol: 7, #https://docs.eversol.one/extras/faq
  blazestake: 10, #https://stake-docs.solblaze.org/features/fees
  jito: 4 #https://jito-foundation.gitbook.io/jitosol/faqs/general-faqs#fees
}

@withdrawal_fees = {
  socean: 0.03,
  marinade: 0,
  jpool: 0.05,
  lido: 0,
  daopool: 0,
  eversol: 0,
  blazestake: 0.3,
  jito: 0.1
}

@deposit_fees = {
  socean: 0.0,
  marinade: 0,
  jpool: 0,
  lido: 0,
  daopool: 0,
  eversol: 0.0,
  blazestake: 0.1,
  jito: 0.3
}

def update_stake_pools(stake_pools)
  stake_pools.each do |sp|
    StakePool.find_or_initialize_by(
      name: sp[:name],
      network: sp[:network]
    ).update(
      ticker: sp[:ticker],
      authority: sp[:authority],
    )
  end
end

def update_stake_pools_fee(stake_pools)
  stake_pools.each do |sp|
    stake_pool = StakePool.find_by(sp)

    key = sp[:name].downcase.to_sym
    stake_pool.update!(
      manager_fee: @manager_fees[key],
      withdrawal_fee: @withdrawal_fees[key],
      deposit_fee: @deposit_fees[key]
    )
  end
end

namespace :add_stake_pool do
  task mainnet: :environment do
    update_stake_pools(@mainnet_stake_pools)
  end

  task testnet: :environment do
    update_stake_pools(@testnet_stake_pools)
  end

  task pythnet: :environment do
    update_stake_pools(@pythnet_stake_pools)
  end
end

# Run the following task if @manager_fees changes
# RAILS_ENV=stage bundle exec rake update_fee_in_stake_pools:mainnet
# RAILS_ENV=production bundle exec rake update_fee_in_stake_pools:mainnet
namespace :update_fee_in_stake_pools do
  task mainnet: :environment do
    update_stake_pools_fee(@mainnet_stake_pools)
  end

  task testnet: :environment do
    update_stake_pools_fee(@testnet_stake_pools)
  end

  task pythnet: :environment do
    update_stake_pools_fee(@pythnet_stake_pools)
  end
end
