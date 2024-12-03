import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import MapComponent from './map_component.vue';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#data-center-map-component',
    store,
    render(createElement) {
      return createElement(MapComponent)
    }
  })
})
