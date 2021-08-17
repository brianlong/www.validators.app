import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import CommissionHistoryRow from './commission_history_row'
// import Pagination from 'vue-pagination-2';
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const chindex = new Vue({
    el: '#commission-histories-index-vue',
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
