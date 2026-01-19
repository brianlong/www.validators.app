import Vue from '../shared/vue_setup'
import TurbolinksAdapter from 'vue-turbolinks';
import CirculatingSupply from './circulating_supply.vue';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#circulating-supply-component',
    store,
    render(createElement) {
      return createElement(CirculatingSupply)
    }
  })
})
