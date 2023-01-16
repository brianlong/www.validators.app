import Vue from 'vue/dist/vue.esm'
import ValidatorSearcherBarTemplate from './validator_searcher_bar_template.vue'
import TurbolinksAdapter from 'vue-turbolinks'
import store from "../stores/main_store.js"
import { BootstrapVue } from 'bootstrap-vue'

Vue.use(TurbolinksAdapter)
Vue.use(BootstrapVue)

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#validator-searcher-bar',
    store,
    render(createElement) {
      return createElement(ValidatorSearcherBarTemplate)
    }
  })
})
