import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import CirculatingSupply from './circulating_supply.vue';
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
    el: '#circulating-supply-stats',
    components: {
      "circulating-supply": CirculatingSupply,
    }
  })
})
