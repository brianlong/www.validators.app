import Vue from 'vue'
import Vuex from 'vuex'
import types from '../mutations/main_mutations_types'
import vuejsStorage from 'vuejs-storage'
Vue.use(Vuex)

const state = {
  mainnet_url: "https://validato-va-34e2.mainnet.rpcpool.com",
  testnet_url: "https://api.testnet.solana.com"
}
const getters = {
  web3_url: function(state, getters) {
    if(location.hostname === "localhost" || getters.network === 'testnet'){
      return state.testnet_url
    } else {
      return state.mainnet_url
    }
  },
  network(state) {
    if(location.href.match(/network=mainnet/)) {
      return 'mainnet'
    } else if(location.href.match(/network=testnet/)) {
      return 'testnet'
    }

    return state.network ? state.network : 'mainnet'
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
