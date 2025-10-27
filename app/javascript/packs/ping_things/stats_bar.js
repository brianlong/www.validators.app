import Vue from '../shared/vue_setup'
import StatsBar from './stats_bar.vue'
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios'
// import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);

// Vue.use(ActionCableVue, {
//   debug: false,
//   debugLevel: "error",
//   connectionUrl: "/cable",
//   connectImmediately: false,
// });

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('ping-thing-stats');
  if (element && !element.__vue__) {
    const pt_stats = new Vue({
      el: '#ping-thing-stats',
      components: {
        "stats-bar": StatsBar
      }
    })
  }
})
