export function stakePoolLogos(stake_pools, size = "small") {
  if(size == "small") {
    return stake_pools.map((stake_pool) => {
      return logosData[stake_pool]["small_logo"]
    })
  } else {
    return stake_pools.map((stake_pool) => {
      return logosData[stake_pool]["large_logo"]
    })
  }
}

const logosData = {
  "BlazeStake": {
    "small_logo": "blazestake-logo.png",
    "large_logo": "blazestake.png",
    "url": "https://stake.solblaze.org/",
  },
  "DAOPool": {
    "small_logo": "daopool-logo.png",
    "large_logo": "daopool.png",
    "url": "https://daopool.monkedao.io",
  },
  "Eversol": {
    "small_logo": "eversol-logo.svg",
    "large_logo": "eversol.png",
    "url": "https://eversol.one/",
  },
  "Jito": {
    "small_logo": "jito-logo.svg",
    "large_logo": "jito.png",
    "url": "https://www.jito.network/",
  },
  "Jpool": {
    "small_logo": "jpool-logo.svg",
    "large_logo": "jpool.png",
    "url": "https://jpool.one",
  },
  "Lido": {
    "small_logo": "lido-logo.svg",
    "large_logo": "lido.png",
    "url": "https://lido.fi/solana",
  },
  "Marinade": {
    "small_logo": "marinade-logo.svg",
    "large_logo": "marinade.png",
    "url": "https://marinade.finance",
  },
  "Socean": {
    "small_logo": "socean-logo.svg",
    "large_logo": "socean.png",
    "url": "https://www.socean.fi",
  },
}
