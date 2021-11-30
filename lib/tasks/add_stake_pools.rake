namespace :add_stake_pool do
  task mainnet: :environment do
    stake_pools = [
      {
        name: "Socean",
        ticker: 'SCNSOL',
        authority: 'AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck',
        network: 'mainnet'
      },
      {
        name: 'Marinade',
        ticker: 'MSOL',
        authority: '9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco',
        network: 'mainnet'
      },
      {
        name: 'Jpool',
        ticker: 'JSOL',
        authority: 'HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt',
        network: 'mainnet'
      },
      {
        name: 'Lido',
        ticker: 'STSOL',
        authority: 'W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5',
        network: 'mainnet'
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

  task testnet: :environment do
    stake_pools = [
      {
        name: 'Jpool',
        authority: '25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT',
        network: 'testnet'
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
