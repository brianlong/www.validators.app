import Vue from 'vue/dist/vue.esm'
import TransactionsStatsComponentTemplate from './transactions_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

// Vue.use(store)

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#transactions-stats-component',
    store,
    render(createElement) {
      return createElement(TransactionsStatsComponentTemplate)
    }
  })
})
