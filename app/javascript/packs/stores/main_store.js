import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  mainnet_url: "https://validato-va-34e2.mainnet.rpcpool.com",
  mainnet_beta_url: "https://api.mainnet-beta.solana.com",
  testnet_url: "https://api.testnet.solana.com",
  pythnet_url: "https://pythnet.rpcpool.com",
  networks: ["mainnet", "testnet", "pythnet"]
}

const getters = {
  web3_url: function(state, getters) {
    if (getters.network === 'mainnet' && location.hostname === "localhost") {
      return state.mainnet_beta_url
    }

    switch (getters.network) {
      case 'mainnet':
        return state.mainnet_url
      case 'pythnet':
        return state.pythnet_url
      case 'testnet':
        return state.testnet_url
      case 'anzamain':
        return state.mainnet_url
    }
  },

  network() {
    if (location.href.match(/network=pythnet/)) {
      return 'pythnet'
    } else if (location.href.match(/network=testnet/)) {
      return 'testnet'
    } else if (location.href.match(/network=anzamain/)) {
      return 'anzamain'
    } else {
      return 'mainnet'
    }
  }
}

export default new Vuex.Store({
  state,
  getters
})
