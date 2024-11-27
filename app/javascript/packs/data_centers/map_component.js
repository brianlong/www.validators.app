import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import MapComponent from './map_component.vue';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#data-center-map-component',
    render(createElement) {
      return createElement(MapComponent)
    }
  })
})
