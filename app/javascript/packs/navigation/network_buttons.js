import Vue from 'vue/dist/vue.esm'
import NetworkButtonsTemplate from './network_buttons_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#network-buttons',
    store,
    render(createElement) {
      return createElement(NetworkButtonsTemplate)
    }
  })
})
