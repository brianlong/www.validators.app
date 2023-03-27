import Vue from 'vue/dist/vue.esm'
import EpochStatsComponentTemplate from './epoch_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#epoch-stats-component',
    store,
    render(createElement) {
      return createElement(EpochStatsComponentTemplate)
    }
  })
})
