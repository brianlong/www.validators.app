import Vue from '../shared/vue_setup'
import TurbolinksAdapter from 'vue-turbolinks';
import DataCenterCharts from './data_center_charts.vue';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#data-center-charts-component',
    store,
    render(createElement) {
      return createElement(DataCenterCharts, {
        props: {
          chart_by: this.$el.attributes.chart_by ? this.$el.attributes.chart_by.value : null
        }
      })
    }
  })
})
