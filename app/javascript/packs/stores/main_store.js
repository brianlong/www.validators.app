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
    if(getters.network === 'testnet') {
      return state.testnet_url
    } else if(getters.network === 'pythnet'){
      return state.pythnet_url
    } else if(location.hostname !== "localhost") {
      return state.mainnet_url
    } else {
      return state.mainnet_beta_url
    }
  },
  network() {
    if(location.href.match(/network=testnet/)) {
      return 'testnet'
    } else if(location.href.match(/network=pythnet/)) {
      return 'pythnet'
    } else {
      return 'mainnet'
    }
  }
}
export default new Vuex.Store({
  state,
  getters
})
