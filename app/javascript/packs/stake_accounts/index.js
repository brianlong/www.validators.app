import Vue from '../shared/vue_setup'
import '../mixins/stake_pools_mixins';

import IndexTemplate from './index_template'
import StakeAccountRow from './stake_account_row'
import ValidatorRow from '../validators/validator_row'
import StakePoolStats from './pool_stats'
import StakePoolsOverview from './pools_overview'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import store from "../stores/main_store.js";

const VueInstance = window.Vue || Vue

VueInstance.component('BPagination', BPagination)
VueInstance.component('stake-account-row', StakeAccountRow)
VueInstance.component('stake-pool-stats', StakePoolStats)
VueInstance.component('stake-pools-overview', StakePoolsOverview)
VueInstance.component('validator-row', ValidatorRow)
VueInstance.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const stake_account_index = new VueInstance({
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
