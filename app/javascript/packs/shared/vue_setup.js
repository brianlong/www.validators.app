import Vue from 'vue'
import Vuex from 'vuex'
import { BootstrapVue } from 'bootstrap-vue'
import store from '../stores/main_store.js'
var moment = require('moment')

// Import all mixins to register their methods globally
import '../mixins/validators_mixins'
import '../mixins/numbers_mixins'
import '../mixins/dates_mixins'
import '../mixins/stake_pools_mixins'
import '../mixins/strings_mixins'
import '../mixins/ping_things_mixins'
import '../mixins/arrays_mixins'

Vue.use(Vuex)
Vue.use(BootstrapVue)

if (!window.globalStore) {
  window.globalStore = store
}

// All methods from mixins are now available globally via imported mixins above

window.Vue = Vue

export default Vue
