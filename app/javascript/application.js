// Entry point for the build script in your package.json
// This replaces app/javascript/packs/application.js

console.log("Application.js loaded successfully!")

// Import jQuery from npm and make it globally available
import $ from 'jquery'
window.$ = window.jQuery = $

// Import Bootstrap JS only (CSS handled by Rails Asset Pipeline)
import 'bootstrap'

// Import application configuration and initialize it synchronously
import './packs/shared/app_config'

// Initialize config data immediately if available
const configElement = document.getElementById('app-config-data');
if (configElement) {
  try {
    const configData = JSON.parse(configElement.textContent);
    // Set up global variables immediately
    window.api_authorization = configData.api_authorization;
    window.google_maps_api_key = configData.google_maps_api_key;
  } catch (error) {
    console.error('Failed to parse app configuration:', error);
  }
}

// Import Turbolinks and start it  
import Turbolinks from "turbolinks"
if (!window.Turbolinks) {
  Turbolinks.start()
  console.log("Turbolinks started")
} else {
  console.log("Turbolinks already loaded, skipping")
}

// Import Rails UJS for handling method: :delete and other Rails helpers
import Rails from "@rails/ujs"
Rails.start()

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
import configuredAxios from "./packs/shared/configured_axios"

// Make configured axios globally available (with authorization)
window.axios = configuredAxios

Vue.use(Vuex)
window.globalStore = store

// Import channels (if they exist)
// import "./channels"

// Import moment
// import moment from "moment"

// Import src files
import './src/sol_prices_charts'
import './src/watch_buttons' 
import './src/chart_links'
import './src/score_modal_trigger'
