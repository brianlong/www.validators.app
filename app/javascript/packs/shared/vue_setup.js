import Vue from 'vue'
import Vuex from 'vuex'
import { BootstrapVue } from 'bootstrap-vue'
import store from '../stores/main_store.js'
var moment = require('moment')

// Disable Vue development mode warnings in console
Vue.config.productionTip = false
Vue.config.devtools = false
Vue.config.silent = true

// Import all mixins to register their methods globally
import '../mixins/arrays_mixins'
import '../mixins/dates_mixins'
import '../mixins/numbers_mixins'
import '../mixins/ping_things_mixins'
import '../mixins/stake_pools_mixins'
import '../mixins/strings_mixins'
import '../mixins/validators_mixins'

Vue.use(Vuex)
Vue.use(BootstrapVue)

if (!window.globalStore) {
  window.globalStore = store
}
window.Vue = Vue

export default Vue
