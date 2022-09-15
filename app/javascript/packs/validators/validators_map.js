import Vue from 'vue/dist/vue.esm'
import ValidatorsMap from './validators_map.vue'
import TurbolinksAdapter from 'vue-turbolinks';
//import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);

// Vue.use(ActionCableVue, {
//   debug: true,
//   debugLevel: "error",
//   connectionUrl: "/cable",
//   connectImmediately: true,
// });

document.addEventListener('turbolinks:load', () => {
  const pt_stats = new Vue({
    el: '#validators-map',
    components: {
      "validators-map": ValidatorsMap
    }
  })
})
