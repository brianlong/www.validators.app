stake_pools = [
  {
    name: "Socean",
    authority: "AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck",
    network: "mainnet",
  },
  {
    name: "Marinade",
    authority: "9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco",
    network: "mainnet",
  },
  {
    name: "Jpool",
    authority: "HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt",
    network: "mainnet",
  },
  {
    name: 'Lido',
    authority: 'W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5',
    network: 'mainnet',
  }
]

manager_fees = {
  socean: 0.16,
  marinade: 2,
  jpool: 0,
  lido: 10
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

namespace :update_fee_in_stake_pools do
  task mainnet: :environment do
    stake_pools.each do |sp|
      stake_pool = StakePool.find_by(sp)

      key = sp[:name].downcase.to_sym
      stake_pool.update!(
        manager_fee: manager_fees[key]
      )
    end
  end
end
