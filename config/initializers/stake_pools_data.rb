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
    manager_fee: 2, #https://www.socean.fi/en/ , https://soceanfi.notion.site/FAQ-e0e2b353a44a4c11b53f614f3dc7b730
    withdrawal_fee: 0.03,
    deposit_fee: 0.0,
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
    deposit_fee: 0,
  },
  jpool: {
    name: "Jpool",
    authority: "HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt",
    network: "mainnet",
    ticker: "jsol",
    small_logo: "jpool-logo.svg",
    large_logo: "jpool.png",
    url: "https://jpool.one",
    manager_fee: 0, #https://jpool.one/pool-info
    withdrawal_fee: 0.05,
    deposit_fee: 0,
  },
  lido: {
    name: "Lido",
    authority: "W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5",
    network: "mainnet",
    ticker: "stsol",
    small_logo: "lido-logo.svg",
    large_logo: "lido.png",
    url: "https://lido.fi/solana",
    manager_fee: 5, #https://solana.lido.fi/
    withdrawal_fee: 0,
    deposit_fee: 0,
  },
  daopool: {
    name: "DAOPool",
    authority: "BbyX1GwUNsfbcoWwnkZDo8sqGmwNDzs2765RpjyQ1pQb",
    network: "mainnet",
    ticker: "daosol",
    small_logo: "daopool-logo.png",
    large_logo: "daopool.png",
    url: "https://daopool.monkedao.io",
    manager_fee: 2,
    withdrawal_fee: 0,
    deposit_fee: 0,
  },
  eversol: {
    name: "Eversol",
    authority: "C4NeuptywfXuyWB9A7H7g5jHVDE8L6Nj2hS53tA71KPn",
    network: "mainnet",
    ticker: "esol",
    small_logo: "eversol-logo.svg",
    large_logo: "eversol.png",
    url: "https://eversol.one/",
    manager_fee: 7, #https://docs.eversol.one/extras/faq
    withdrawal_fee: 0,
    deposit_fee: 0,
  },
  blazestake: {
    name: "BlazeStake",
    authority: "6WecYymEARvjG5ZyqkrVQ6YkhPfujNzWpSPwNKXHCbV2",
    network: "mainnet",
    ticker: "bsol",
    small_logo: "blazestake-logo.png",
    large_logo: "blazestake.png",
    url: "https://stake.solblaze.org/",
    manager_fee: 5, #https://stake-docs.solblaze.org/features/fees
    withdrawal_fee: 0.1,
    deposit_fee: 0,
  },
  jito: {
    name: "Jito",
    authority: "6iQKfEyhr3bZMotVkW6beNZz5CPAkiwvgV2CTje9pVSS",
    network: "mainnet",
    ticker: "jitosol",
    small_logo: "jito-logo.svg",
    large_logo: "jito.png",
    url: "https://www.jito.network/",
    manager_fee: 4, #https://jito-foundation.gitbook.io/jitosol/faqs/general-faqs#fees
    withdrawal_fee: 0.1,
    deposit_fee: 0,
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