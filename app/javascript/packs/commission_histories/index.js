import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import commission_history_row from './commission_history_row'

document.addEventListener('DOMContentLoaded', () => {
  const chindex = new Vue({
    el: '#commission-histories-index-vue',
    render: h => h(IndexTemplate),
    component: {
      'commission-history-row': commission_history_row
    }
  })
})
