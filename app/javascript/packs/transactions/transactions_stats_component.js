import Vue from 'vue/dist/vue.esm'
import TransactionsStatsComponentTemplate from './transactions_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#transactions-stats-component',
    render(createElement) {
      return createElement(TransactionsStatsComponentTemplate)
    }
  })
})
