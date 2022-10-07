import Vue from 'vue/dist/vue.esm'
import SolPricesComponentTemplate from './sol_price_component_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#sol-price-component',
    render(createElement) {
      return createElement(SolPricesComponentTemplate)
    }
  })
})
