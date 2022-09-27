import Vue from 'vue/dist/vue.esm'
import ValidatorsMap from './validators_map.vue'
import TurbolinksAdapter from 'vue-turbolinks';
Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const pt_stats = new Vue({
    el: '#validators-map',
    components: {
      "validators-map": ValidatorsMap
    }
  })
})
