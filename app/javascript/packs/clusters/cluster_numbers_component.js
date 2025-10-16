import Vue from 'vue/dist/vue.esm'
import ClusterNumbersTemplate from './cluster_numbers_component.vue'
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
  const chindex = new Vue({
    el: '#cluster-numbers-component',
    store,
    render(createElement) {
      return createElement(ClusterNumbersTemplate)
    }
  })
})
