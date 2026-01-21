# frozen_string_literal: true

MAINNET_STAKE_POOLS = {
  marinade: {
    name: "Marinade",
    authority: "9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco",
    network: "mainnet",
    ticker: "msol",
    small_logo: "marinade-logo.svg",
    large_logo: "marinade.png",
    url: "https://marinade.finance",
    manager_fee: 9.5, #https://docs.marinade.finance/marinade-protocol/faq
    withdrawal_fee: 0.05,
    deposit_fee: 0
  },
  jpool: {
    name: "Jpool",
    authority: "HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt",
    network: "mainnet",
    ticker: "jsol",
    small_logo: "jpool-logo.svg",
    large_logo: "jpool.png",
    url: "https://jpool.one",
    manager_fee: 7, #https://jpool.one/pool-info
    withdrawal_fee: 0.38,
    deposit_fee: 0
  },
  daopool: {
    name: "DAOPool",
    authority: "BbyX1GwUNsfbcoWwnkZDo8sqGmwNDzs2765RpjyQ1pQb",
    network: "mainnet",
    ticker: "daosol",
    small_logo: "daopool-logo.png",
    large_logo: "daopool.png",
    url: "https://daopool.monkedao.io",
    manager_fee: 2, #https://daopool.io/faq
    withdrawal_fee: 0.3,
    deposit_fee: 0
  },
  blazestake: {
    name: "BlazeStake",
    authority: "6WecYymEARvjG5ZyqkrVQ6YkhPfujNzWpSPwNKXHCbV2",
    network: "mainnet",
    ticker: "bsol",
    small_logo: "blazestake-logo.png",
    large_logo: "blazestake.png",
    url: "https://stake.solblaze.org",
    manager_fee: 0, #https://stake-docs.solblaze.org/features/fees
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  jito: {
    name: "Jito",
    authority: "6iQKfEyhr3bZMotVkW6beNZz5CPAkiwvgV2CTje9pVSS",
    network: "mainnet",
    ticker: "jitosol",
    small_logo: "jito-logo.svg",
    large_logo: "jito.png",
    url: "https://www.jito.network",
    manager_fee: 5, #https://jito-foundation.gitbook.io/mev/jito-solana/faqs
    withdrawal_fee: 0,
    deposit_fee: 0
  },
  edgevana: {
    name: "Edgevana",
    authority: "FZEaZMmrRC3PDPFMzqooKLS2JjoyVkKNd2MkHjr7Xvyq",
    network: "mainnet",
    ticker: "edgesol",
    small_logo: "edgevana-logo.svg",
    large_logo: "edgevana.png",
    url: "https://stake.edgevana.com/",
    manager_fee: 1, #https://docs.stake.edgevana.com/docs/pool-and-token-info/fees
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  aero: {
    name: "Aero",
    authority: "AKJt3m2xJ6ANda9adBGqb5BMrheKJSwxyCfYkLuZNmjn",
    network: "mainnet",
    ticker: "aerosol",
    small_logo: "aero-logo.svg",
    large_logo: "aero.png",
    url: "https://aeropool.io",
    manager_fee: 5,
    withdrawal_fee: 0.1,
    deposit_fee: 0.1
  },
  shinobi: {
    name: "Shinobi",
    authority: "EpH4ZKSeViL5qAHA9QANYVHxdmuzbUH2T79f32DmSCaM",
    network: "mainnet",
    ticker: "xshin",
    small_logo: "shinobi-logo.png",
    large_logo: "shinobi.png",
    url: "https://xshin.fi/",
    manager_fee: 4,
    withdrawal_fee: 0.03,
    deposit_fee: 0.1
  },
  vault: {
    name: "Vault",
    authority: "GdNXJobf8fbTR5JSE7adxa6niaygjx4EEbnnRaDCHMMW",
    network: "mainnet",
    ticker: "vsol",
    small_logo: "vault-logo.png",
    large_logo: "vault.png",
    url: "https://thevault.finance/",
    manager_fee: 5, #https://docs.thevault.finance/about/the-vault-fees
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  dynosol: {
    name: "DynoSol",
    authority: "BqPJdYKKpReEfXHv8kgdmRcBfLToBSHpt1qThtb52GSs",
    network: "mainnet",
    ticker: "dynosol",
    small_logo: "dynosol-logo.png",
    large_logo: "dynosol.png",
    url: "https://dynosol.io/",
    manager_fee: 5, #https://docs.dynosol.io/Fees-1eaddc3951038070a35cda8b72e5707d
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  jagpool: {
    name: "JagPool",
    authority: "Hodkwm8xf43JzRuKNYPGnYJ7V9cXZ7LJGNy96TWQiSGN",
    network: "mainnet",
    ticker: "jagsol",
    small_logo: "jagpool-logo.png",
    large_logo: "jagpool.png",
    url: "https://www.jagpool.xyz/",
    manager_fee: 5,
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  definity: {
    name: "Definity",
    authority: "5ugu8RogBq5ZdfGt4hKxKotRBkndiV1ndsqWCf7PBmST",
    network: "mainnet",
    ticker: "definsol",
    small_logo: "definsol-logo.png",
    large_logo: "definsol.png",
    url: "https://www.definity.finance/",
    manager_fee: 5,
    withdrawal_fee: 0.1,
    deposit_fee: 0
  },
  doublezero: {
    name: "DoubleZero",
    authority: "4cpnpiwgBfUgELVwNYiecwGti45YHSH3R72CPkFTiwJt",
    network: "mainnet",
    ticker: "dzsol",
    small_logo: "doublezero.svg",
    large_logo: "doublezero_lg.svg",
    url: "https://doublezero.xyz/staking",
    manager_fee: 5,
    withdrawal_fee: 0,
    deposit_fee: 0
  },
  socean: {
    # name: "Socean",
    # authority: "AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck",
    # network: "mainnet",
    # ticker: "scnsol",
    # small_logo: "socean-logo.svg",
    # large_logo: "socean.png",
    # url: "https://www.socean.fi",
    # manager_fee: 2, #https://www.socean.fi/en
    # withdrawal_fee: 0.03,
    # deposit_fee: 0,
    deleted: true
  },
  lido: {
    # name: "Lido",
    # authority: "W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5",
    # network: "mainnet",
    # ticker: "stsol",
    # small_logo: "lido-logo.svg",
    # large_logo: "lido.png",
    # url: "https://lido.fi/solana",
    # manager_fee: 5, #https://solana.lido.fi
    # withdrawal_fee: 0,
    # deposit_fee: 0,
    deleted: true
  },
  zippystake: {
    # name: "ZippyStake",
    # authority: "F15nfVkJFAa3H4BaHEb6hQBnmiJZwPYioDiE1yxbc5y4",
    # network: "mainnet",
    # ticker: "zippysol",
    # small_logo: "zippystake-logo.svg",
    # large_logo: "zippystake.png",
    # url: "https://www.zippystake.org",
    # manager_fee: 3, #https://docs.zippystake.org
    # withdrawal_fee: 0.1,
    # deposit_fee: 0
    deleted: true
  },

}

TESTNET_STAKE_POOLS = {
  jpool: {
    name: "Jpool",
    authority: "25jjjw9kBPoHtCLEoWu2zx6ZdXEYKPUbZ6zweJ561rbT",
    network: "testnet",
    ticker: "jsol",
    small_logo: "jpool-logo.svg",
    large_logo: "jpool.png",
    url: "https://jpool.one",
  }
}

PYTHNET_STAKE_POOLS = {}
