import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import ActiveStake from './active_stake.vue';
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
    el: '#active-stake-stats',
    components: {
      "active-stake": ActiveStake,
    }
  })
})
