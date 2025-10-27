import Vue from '../shared/vue_setup'
import ValidatorsMapComponentTemplate from './validators_map.vue'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('validators-map');
  if (element && !element.__vue__) {
    new Vue({
      el: '#validators-map',
      store,
      components: {
        "validators-map": ValidatorsMapComponentTemplate
      }
    })
  }
})
