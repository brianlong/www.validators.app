# frozen_string_literal: true

MAINNET_STAKE_POOLS = {
  socean: {
    name: "Socean",
    authority: "AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck",
    network: "mainnet",
    ticker: "scnsol",
    small_logo: "socean-logo.svg",
    large_logo: "socean.png",
    url: "https://www.socean.fi",
    manager_fee: 2, #https://www.socean.fi/en
    withdrawal_fee: 0.03,
    deposit_fee: 0
  },
  marinade: {
    name: "Marinade",
    authority: "9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco",
    network: "mainnet",
    ticker: "msol",
    small_logo: "marinade-logo.svg",
    large_logo: "marinade.png",
    url: "https://marinade.finance",
    manager_fee: 6, #https://docs.marinade.finance/faq/faq
    withdrawal_fee: 0,
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
    manager_fee: 5, #https://jpool.one/pool-info
    withdrawal_fee: 0.11,
    deposit_fee: 0
  },
  lido: {
    name: "Lido",
    authority: "W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5",
    network: "mainnet",
    ticker: "stsol",
    small_logo: "lido-logo.svg",
    large_logo: "lido.png",
    url: "https://lido.fi/solana",
    manager_fee: 5, #https://solana.lido.fi
    withdrawal_fee: 0,
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
    manager_fee: 5, #https://stake-docs.solblaze.org/features/fees
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
    manager_fee: 4, #https://jito-foundation.gitbook.io/mev/jito-solana/faqs
    withdrawal_fee: 0,
    deposit_fee: 0
  },
  zippystake: {
    name: "ZippyStake",
    authority: "F15nfVkJFAa3H4BaHEb6hQBnmiJZwPYioDiE1yxbc5y4",
    network: "mainnet",
    ticker: "zippysol",
    small_logo: "zippystake-logo.svg",
    large_logo: "zippystake.png",
    url: "https://www.zippystake.org",
    manager_fee: 3, #https://docs.zippystake.org
    withdrawal_fee: 0.1,
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
    manger_fee: 5,
    withdrawal_fee: 0.1,
    deposit_fee: 0.1
  }
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
