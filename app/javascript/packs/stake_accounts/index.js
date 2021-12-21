import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import StakeAccountRow from './stake_account_row'
import StakePoolStats from './pool_stats'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const stake_account_index = new Vue({
    el: '#stake-accounts-index-vue',    
    render(createElement) {
      return createElement(IndexTemplate, {
        props: {
          network: this.$el.attributes.network ? this.$el.attributes.network.value : 'mainnet'
        }
      })
    },
    component: {
      'StakeAccountRow': StakeAccountRow,
      'StakePoolStats': StakePoolStats,
      'BPagination': BPagination
    }
  })
})
