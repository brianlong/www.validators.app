import Vue from 'vue/dist/vue.esm'
import ValidatorsMapComponentTemplate from './validators_map.vue'
import ValidatorsMapDataCenterDetailsComponent from './validators_map_data_center_details'
import ValidatorsMapLeadersComponent from "./validators_map_leaders";
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
  new Vue({
    el: '#validators-map',
    store,
    components: {
      "validators-map": ValidatorsMapComponentTemplate,
      "validators-map-data-center-details": ValidatorsMapDataCenterDetailsComponent,
      "validators-map-leaders": ValidatorsMapLeadersComponent
    }
  })
})
