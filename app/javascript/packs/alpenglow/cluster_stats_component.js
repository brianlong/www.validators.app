import Vue from 'vue/dist/vue.esm'
import ClusterStatsComponentTemplate from './cluster_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#alpenglow-cluster-stats-component',
    store,
    render(createElement) {
      return createElement(ClusterStatsComponentTemplate)
    }
  })
})
