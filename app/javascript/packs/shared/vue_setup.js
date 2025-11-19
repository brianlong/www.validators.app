import Vue from 'vue'
import Vuex from 'vuex'
import { BootstrapVue } from 'bootstrap-vue'
import store from '../stores/main_store.js'
import axios from 'axios'
import { STAKE_POOLS_CONFIG, getAssetPath } from '../mixins/stake_pools_mixins'
var moment = require('moment')

Vue.use(Vuex)
Vue.use(BootstrapVue)

if (!window.globalStore) {
  window.globalStore = store
}

axios.interceptors.request.use(function (config) {
  if (window.api_authorization && typeof window.api_authorization === 'string') {
    config.headers.Authorization = window.api_authorization;
  }
  return config;
}, function (error) {
  return Promise.reject(error);
});

Vue.mixin({
  methods: {
    // From strings_mixins.js
    capitalize(word) {
      return word[0].toUpperCase() + word.slice(1)
    },

    pluralize(number, word) {
      if (typeof number !== 'number') return word;
      if(number > 1) {
        return ' ' + word + "s"
      } else {
        return ' ' + word
      }
    },

    // From validators_mixins.js
    avatar_url(validator) {
      if(validator['avatar_file_url']) {
        return validator['avatar_file_url']
      } else {
        return window.default_avatar_url || '/assets/default-avatar.png'
      }
    },

    truncate(key) {
      return key.substring(0, 6) + "..." + key.substring(key.length - 4)
    },

    validator_url(validator_account, network) {
      return "/validators/" + validator_account + "?network=" + network
    },

    vote_account_url(validator_account, vote_account, network) {
      return "/validators/" + validator_account + "/vote_accounts/" + vote_account + "?network=" + network
    },

    // From numbers_mixins.js
    thousands_separator(number) {
      if (!number && number !== 0) return ''
      return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    number_with_precision(number, precision) {
      if (!number && number !== 0) return ''
      return parseFloat(number).toFixed(precision);
    },

    // From dates_mixins.js  
    time_ago_in_words(date) {
      if (!date) return ''
      const now = new Date()
      const past = new Date(date)
      const diffInSeconds = Math.floor((now - past) / 1000)
      
      if (diffInSeconds < 60) return `${diffInSeconds} seconds ago`
      if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} minutes ago`  
      if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} hours ago`
      return `${Math.floor(diffInSeconds / 86400)} days ago`
    },

    date_time_with_timezone(date) {
      return moment(new Date(date)).utc().format('YYYY-MM-DD HH:mm:ss z')
    },

    // Additional numbers mixins
    lamports_to_sol(lamports) {
      return lamports / 1000000000
    },

    // Additional validators mixins
    skipped_vote_percent(validator, batch) {
      if(validator['skipped_vote_history'] && batch['best_skipped_vote']) {
        const history_array = validator['skipped_vote_history']
        const skipped_votes_percent = history_array[history_array.length - 1]

        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).toFixed(2) : null
      } else {
        return null
      }
    },

    skipped_vote_percent_string(skipped_vote_value) {
      return skipped_vote_value ? skipped_vote_value + "%" : "N / A"
    },

    shortened_validator_name(name, account) {
      if(name) {
        return name
      } else {
        return this.shorten_key(account)
      }
    },

    shorten_key(key) {
      return key.substring(0, 6) + "..." + key.substring(key.length - 4)
    },

    jito_maximum_commission(validator) {
      if(validator['jito'] && parseInt(validator['jito_commission']) <= 1000) {
        return true
      } else {
        return false
      }
    },

    // Array helpers
    arrays_equal(array1, array2) {
      let a = array1.sort();
      let b = array2.sort();
      return Array.isArray(a) &&
        Array.isArray(b) &&
        a.length === b.length &&
        a.every((val, index) => val === b[index]);
    },

    // Stake pools helpers (using STAKE_POOLS_CONFIG from mixins)
    stake_pool_small_logo(stake_pool) {
      const config = STAKE_POOLS_CONFIG[stake_pool.toLowerCase()];
      return config ? getAssetPath(config.small_logo) : "";
    },

    stake_pool_large_logo(stake_pool) {
      const config = STAKE_POOLS_CONFIG[stake_pool.toLowerCase()];
      return config ? getAssetPath(config.large_logo) : "";
    },

    // From ping_things_mixins.js
    fails_count_percentage: function(fails_count, num_of_records) {
      return fails_count ? '(' + (fails_count / num_of_records * 100).toLocaleString('en-US', {maximumFractionDigits: 1}) + '%)' : ''
    }
  }
})

window.Vue = Vue

export default Vue
