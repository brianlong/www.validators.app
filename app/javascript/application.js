// Entry point for the build script in your package.json
// This replaces app/javascript/packs/application.js

import $ from 'jquery'
window.$ = window.jQuery = $

import 'bootstrap'
import './packs/shared/app_config'

const configElement = document.getElementById('app-config-data');
if (configElement) {
  try {
    const configData = JSON.parse(configElement.textContent);
    // Ensure api_authorization is a string
    if (typeof configData.api_authorization === 'string') {
      window.api_authorization = configData.api_authorization;
    }
    if (typeof configData.google_maps_api_key === 'string') {
      window.google_maps_api_key = configData.google_maps_api_key;
    }
  } catch (error) {
    console.error('Failed to parse app configuration:', error);
  }
}

import Turbolinks from "turbolinks"
if (!window.Turbolinks) {
  Turbolinks.start()
}

import Rails from "@rails/ujs"
Rails.start()

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

const ActionCable = require('@rails/actioncable')
if (!window.ActionCableConnection) {
  window.ActionCableConnection = ActionCable.createConsumer('/cable')
}

import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import store from "./packs/stores/main_store.js"
import configuredAxios from "./packs/shared/configured_axios"

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
