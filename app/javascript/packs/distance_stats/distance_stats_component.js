import Vue from 'vue/dist/vue.esm';
import DistanceStatsComponentTemplate from './distance_stats_component_template';
import TurbolinksAdapter from 'vue-turbolinks';
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
    render(createElement) {
      return createElement(DistanceStatsComponentTemplate);
    }
  })
})
