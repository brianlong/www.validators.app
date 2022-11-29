import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import CommissionHistoryRow from './commission_history_row'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import store from "../stores/main_store.js";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const chindex = new Vue({
    el: '#commission-histories-index-vue',
    store,
    render(createElement) {
      return createElement(IndexTemplate, {
        props: {
          query: this.$el.attributes.query ? this.$el.attributes.query.value : null
        }
      })
    },
    component: {
      'CommissionHistoryRow': CommissionHistoryRow,
      'BPagination': BPagination
    }
  })
})
