import Vue from '../shared/vue_setup'
import IndexTemplate from './index_template'
import StakeAccountRow from './stake_account_row'
import ValidatorRow from '../validators/validator_row'
import StakePoolStats from './pool_stats'
import StakePoolsOverview from './pools_overview'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import store from "../stores/main_store.js";

Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const stake_account_index = new Vue({
    el: '#stake-accounts-index-vue',
    store,
    components: {
      'stake-account-row': StakeAccountRow,
      'stake-pool-stats': StakePoolStats,
      'stake-pools-overview': StakePoolsOverview,
      'validator-row': ValidatorRow,
      'BPagination': BPagination
    },
    render(createElement) {
      return createElement(IndexTemplate);
    }
  })
})
