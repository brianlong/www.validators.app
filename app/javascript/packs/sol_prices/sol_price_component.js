import Vue from 'vue/dist/vue.esm'
import SolPricesComponentTemplate from './sol_price_component_template'
import TurbolinksAdapter from 'vue-turbolinks';
import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#sol-price-component',
    render(createElement) {
      return createElement(SolPricesComponentTemplate)
    }
  })
})
