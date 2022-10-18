import Vue from 'vue'
import Vuex from 'vuex'
import types from '../mutations/main_mutations_types'
import vuejsStorage from 'vuejs-storage'
Vue.use(Vuex)

const state = {
  default_url: "https://validato-va-34e2.mainnet.rpcpool.com",
  localhost_url: "https://api.testnet.solana.com"
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
const mutations = {
  set_network(state, network) {
    state.network = network
  }
}
const actions = {
  set_network(context, network) {
    context.commit(types.SET_NETWORK, network)
  }
}
const plugins = [
  vuejsStorage({
    keys: ['network'],
    namespace: 'validators',
    driver: vuejsStorage.drivers.sessionStorage
  })
]
export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations,
  plugins
})
