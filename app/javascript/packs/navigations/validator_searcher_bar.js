import Vue from '../shared/vue_setup'
import ValidatorSearcherBarTemplate from './validator_searcher_bar_template.vue'
import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  if (document.getElementById('validator-searcher-bar') && window.globalStore) {
    new Vue({
      el: '#validator-searcher-bar',
      store: window.globalStore,
      render(createElement) {
        return createElement(ValidatorSearcherBarTemplate)
      }
    })
  }
})
