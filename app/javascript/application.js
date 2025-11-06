// Entry point for the build script in your package.json
// This replaces app/javascript/packs/application.js

console.log("Application.js loaded successfully!")

// Import application configuration
import './packs/shared/app_config'

// Import Turbolinks and start it  
import Turbolinks from "turbolinks"
if (!window.Turbolinks) {
  Turbolinks.start()
  console.log("Turbolinks started")
} else {
  console.log("Turbolinks already loaded, skipping")
}

// Import Active Storage and start it
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

console.log("Rails, Turbolinks, and ActiveStorage started")

// Setup ActionCable globally - available for all entry points
const ActionCable = require('@rails/actioncable')
if (!window.ActionCableConnection) {
  window.ActionCableConnection = ActionCable.createConsumer('/cable')
  console.log('Native ActionCable connected')
}

// Import and setup global Vuex store
import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import store from "./packs/stores/main_store.js"
import axios from 'axios'

Vue.use(Vuex)
window.globalStore = store

// Import mixins globally
import "./packs/mixins/validators_mixins"
import "./packs/mixins/numbers_mixins"
import "./packs/mixins/dates_mixins"
import "./packs/mixins/stake_pools_mixins"
import "./packs/mixins/strings_mixins"
import "./packs/mixins/ping_things_mixins"
import "./packs/mixins/arrays_mixins"

// Setup axios authorization interceptor globally
axios.interceptors.request.use(function (config) {
  // Only add authorization header if it's a valid string
  if (window.api_authorization && typeof window.api_authorization === 'string') {
    config.headers.Authorization = window.api_authorization;
  }
  return config;
}, function (error) {
  return Promise.reject(error);
});

// Import channels (if they exist)
// import "./channels"

// Import moment
// import moment from "moment"

// Import src files (commenting out for now)
// import './src/sol_prices_charts'
// import './src/watch_buttons' 
// import './src/chart_links'
// import './src/score_modal_trigger'
