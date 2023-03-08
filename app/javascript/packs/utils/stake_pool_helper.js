export function stakePoolLogoUrls(stake_pools) {
  return stake_pools.map((stake_pool) => {
    return logoUrl[stake_pool]
  })
}

const logoUrl = {
  "Socean": "socean-logo.svg",
  "Marinade": "marinade-logo.svg",
  "Jpool": "jpool-logo.svg",
  "Lido": "lido-logo.svg",
  "DAOPool": "daopool-logo.png",
  "Eversol": "eversol-logo.svg",
  "BlazeStake": "blazestake-logo.png",
  "Jito": "jito-logo.svg"
}
