import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)
const state = {
  default_url: "https://validato-va-34e2.mainnet.rpcpool.com",
  localhost_url: "https://api.mainnet-beta.solana.com"
}
const getters = {
  web3_url: function(state) {
    if(location.hostname === "localhost"){
      return state.localhost_url
    } else {
      return state.default_url
    }
  }
}
export default new Vuex.Store({
  state,
  getters
})
