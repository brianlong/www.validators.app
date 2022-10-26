import Vue from 'vue/dist/vue.esm';
import LeadersStatsComponentTemplate from './leaders_stats_component_template';
import TurbolinksAdapter from 'vue-turbolinks';
import ActionCableVue from "actioncable-vue";
import store from "../stores/main_store.js";

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
    store,
    render(createElement) {
      return createElement(LeadersStatsComponentTemplate);
    }
  })
})
