import Vue from 'vue';

export const STAKE_POOLS_CONFIG = {
  "marinade": {
    small_logo: "marinade-logo.svg",
    large_logo: "marinade.png"
  },
  "jpool": {
    small_logo: "jpool-logo.svg",
    large_logo: "jpool.png"
  },
  "daopool": {
    small_logo: "daopool-logo.png",
    large_logo: "daopool.png"
  },
  "blazestake": {
    small_logo: "blazestake-logo.png",
    large_logo: "blazestake.png"
  },
  "jito": {
    small_logo: "jito-logo.svg",
    large_logo: "jito.png"
  },
  "edgevana": {
    small_logo: "edgevana-logo.svg",
    large_logo: "edgevana.png"
  },
  "aero": {
    small_logo: "aero-logo.svg",
    large_logo: "aero.png"
  },
  "shinobi": {
    small_logo: "shinobi-logo.png",
    large_logo: "shinobi.png"
  },
  "vault": {
    small_logo: "vault-logo.png",
    large_logo: "vault.png"
  },
  "socean": {
    small_logo: "socean-logo.svg",
    large_logo: "socean.png"
  },
  "lido": {
    small_logo: "lido-logo.svg",
    large_logo: "lido.png"
  },
  "zippystake": {
    small_logo: "zippystake-logo.svg",
    large_logo: "zippystake.png"
  },
  "jagpool": {
    small_logo: "jagpool-logo.png",
    large_logo: "jagpool.png"
  },
  "dynosol": {
    small_logo: "dynosol-logo.png",
    large_logo: "dynosol.png"
  },
  "definity": {
    small_logo: "definsol-logo.png",
    large_logo: "definsol.png"
  }
}

export function getAssetPath(filename) {
  if (window.asset_path_helper) {
    return window.asset_path_helper(filename);
  }
  return `/assets/${filename}`;
}

Vue.mixin({
  methods: {
    stake_pool_small_logo(stake_pool) {
      const config = STAKE_POOLS_CONFIG[stake_pool.toLowerCase()];
      return config ? getAssetPath(config.small_logo) : null;
    },
    stake_pool_large_logo(stake_pool) {
      const config = STAKE_POOLS_CONFIG[stake_pool.toLowerCase()];
      return config ? getAssetPath(config.large_logo) : null;
    },
  }
});
