import Vue from 'vue/dist/vue.esm'
import ValidatorsMap from './validators_map.vue'
import ValidatorsMapDataCenterDetails from './validators_map_data_center_details'
import TurbolinksAdapter from 'vue-turbolinks';
Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#validators-map',
    components: {
      "validators-map": ValidatorsMap,
      "validators-map-data-center-details": ValidatorsMapDataCenterDetails,
    }
  })
})