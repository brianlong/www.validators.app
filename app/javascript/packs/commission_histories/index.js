import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import CommissionHistoryRow from './commission_history_row'
// import TurbolinksAdapter from 'vue-turbolinks';

document.addEventListener('DOMContentLoaded', () => {
  const chindex = new Vue({
    el: '#commission-histories-index-vue',
    render: h => h(IndexTemplate),
    component: {
      'CommissionHistoryRow': CommissionHistoryRow
    }
  })
})
