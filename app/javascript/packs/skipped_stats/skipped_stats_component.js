import Vue from 'vue/dist/vue.esm';
import SkippedStatsComponentTemplate from './skipped_stats_component_template';
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
    el: '#skipped-stats-component',
    render(createElement) {
      return createElement(SkippedStatsComponentTemplate);
    }
  })
})
