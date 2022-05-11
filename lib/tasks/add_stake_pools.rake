stake_pools = [
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
  }
]

manager_fees = {
  socean: 2,
  marinade: 2,
  jpool: 0,
  lido: 10,
  daopool: 2,
  eversol: 0
}

withdrawal_fees = {
  socean: 0.3,
  marinade: 0,
  jpool: 0,
  lido: 0,
  daopool: 0,
  eversol: 0
}

deposit_fees = {
  socean: 0.15,
  marinade: 0,
  jpool: 0,
  lido: 0,
  daopool: 0,
  eversol: 0.25
}

namespace :add_stake_pool do
  task mainnet: :environment do
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

  task testnet: :environment do
    stake_pools = [
      {
        name: "Jpool",
        authority: "25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT",
        network: "testnet"
      }
    ]

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
end

# Run the following task if manager_fees changes
# RAILS_ENV=stage bundle exec rake update_fee_in_stake_pools:mainnet
# RAILS_ENV=production bundle exec rake update_fee_in_stake_pools:mainnet
namespace :update_fee_in_stake_pools do
  task mainnet: :environment do
    stake_pools.each do |sp|
      stake_pool = StakePool.find_by(sp)

      key = sp[:name].downcase.to_sym
      stake_pool.update!(
        manager_fee: manager_fees[key],
        withdrawal_fee: withdrawal_fees[key],
        deposit_fee: deposit_fees[key]
      )
    end
  end
end
