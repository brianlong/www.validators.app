namespace :add_stake_pool do
  task mainnet: :environment do
    stake_pools = [
      {
        name: "Socean",
        authority: 'AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck',
        network: 'mainnet'
      },
      {
        name: 'Marinade',
        authority: '9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco',
        network: 'mainnet'
      },
      {
        name: 'Jpool',
        authority: '25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT',
        network: 'mainnet'
      }
    ]

    stake_pools.each do |sp|
      StakePool.find_or_create_by(sp)
    end
  end

  task testnet: :environment do
    stake_pools = [
      {
        name: 'Jpool',
        authority: '25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT',
        network: 'mainnet'
      }
    ]

    stake_pools.each do |sp|
      StakePool.find_or_create_by(sp)
    end
  end
end
