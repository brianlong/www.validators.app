import Vue from 'vue/dist/vue.esm'
import ClusterStatsComponentTemplate from './cluster_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import { BPagination } from "bootstrap-vue";
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);
Vue.component('BPagination', BPagination)

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#alpenglow-cluster-stats-component',
    store,
    render(createElement) {
      return createElement(ClusterStatsComponentTemplate)
    }
  })
})
