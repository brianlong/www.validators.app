import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  mainnet_url: "https://validato-va-34e2.mainnet.rpcpool.com",
  mainnet_beta_url: "https://api.mainnet-beta.solana.com",
  testnet_url: "https://api.testnet.solana.com"
}
const getters = {
  web3_url: function(state, getters) {
    if(getters.network === 'testnet') {
      return state.testnet_url
    } else if(location.hostname !== "localhost") {
      return state.mainnet_url
    } else {
      return state.mainnet_beta_url
    }
  },
  network() {
    return location.href.match(/network=testnet/) ? 'testnet' : 'mainnet'
  }
}
export default new Vuex.Store({
  state,
  getters
})
