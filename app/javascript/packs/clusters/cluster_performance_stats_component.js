import Vue from 'vue/dist/vue.esm';
import DistanceStatsComponentTemplate from './cluster_performance_stats_component_template';
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";
import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#distance-stats-component',
    store,
    render(createElement) {
      return createElement(DistanceStatsComponentTemplate);
    }
  })
})