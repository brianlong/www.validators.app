import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import ActiveStake from './active_stake.vue';
Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#active-stake-stats',
    components: {
      "active-stake": ActiveStake,
    }
  })
})
