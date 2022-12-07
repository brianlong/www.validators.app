import Vue from 'vue/dist/vue.esm'
import HistoricalSolPricesComponentTemplate from './historical_sol_prices_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#historical-sol-prices-component',
    store,
    render(createElement) {
      return createElement(HistoricalSolPricesComponentTemplate)
    }
  })
})
