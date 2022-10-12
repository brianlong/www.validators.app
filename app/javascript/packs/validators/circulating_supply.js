import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import CirculatingSupply from './circulating_supply.vue';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#circulating-supply-component',
    render(createElement) {
      return createElement(CirculatingSupply)
    }
  })
})
