import Vue from '../shared/vue_setup'
import SoftwareVersionsTemplate from './software_versions_template'
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
    el: '#software-versions-component',
    store,
    render(createElement) {
      return createElement(SoftwareVersionsTemplate)
    }
  })
})
