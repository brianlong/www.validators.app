import Vue from 'vue/dist/vue.esm';
import LeadersStatsComponentTemplate from './leaders_stats_component_template';
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
    el: '#leader-stats-component',
    render(createElement) {
      return createElement(LeadersStatsComponentTemplate);
    }
  })
})
