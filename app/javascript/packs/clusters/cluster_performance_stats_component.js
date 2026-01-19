import Vue from '../shared/vue_setup';
import ClusterPerformanceStatsComponentTemplate from './cluster_performance_stats_component_template';
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#cluster-performance-stats-component',
    store,
    render(createElement) {
      return createElement(ClusterPerformanceStatsComponentTemplate);
    }
  })
})
