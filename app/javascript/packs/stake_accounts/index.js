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

Vue.component('BPagination', BPagination)
Vue.component('StakeAccountRow', StakeAccountRow)
Vue.component('StakePoolStats', StakePoolStats)
Vue.component('StakePoolsOverview', StakePoolsOverview)
Vue.component('ValidatorRow', ValidatorRow)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const stake_account_index = new Vue({
    el: '#stake-accounts-index-vue',
    store,
    render(createElement) {
      return createElement(IndexTemplate);
    }
  })
})
