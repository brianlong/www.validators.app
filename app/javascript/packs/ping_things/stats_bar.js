import Vue from 'vue/dist/vue.esm'
import StatsBar from './stats_bar.vue'
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios'
import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);

axios.defaults.headers.get["Authorization"] = window.api_authorization

Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

document.addEventListener('turbolinks:load', () => {
  const pt_stats = new Vue({
    el: '#ping-thing-stats',
    components: {
      "stats-bar": StatsBar
    }
  })
})
