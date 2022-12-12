import Vue from 'vue/dist/vue.esm'
import ValidatorSearcherTemplate from './validator_searcher_template.vue'
import TurbolinksAdapter from 'vue-turbolinks'
import store from "../stores/main_store.js"
import { BootstrapVue } from 'bootstrap-vue'

Vue.use(TurbolinksAdapter)
Vue.use(BootstrapVue)

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#validator-searcher',
    store,
    render(createElement) {
      return createElement(ValidatorSearcherTemplate)
    }
  })
})
