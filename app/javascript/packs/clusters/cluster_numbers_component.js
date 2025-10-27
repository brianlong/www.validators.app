import Vue from '../shared/vue_setup'
import ClusterNumbersTemplate from './cluster_numbers_component.vue'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#cluster-numbers-component',
    store,
    render(createElement) {
      return createElement(ClusterNumbersTemplate)
    }
  })
})
