import Vue from 'vue/dist/vue.esm'
import ValidatorSearcherBtnTemplate from './validator_searcher_btn_template.vue'
import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#validator-searcher-btn',
    render(createElement) {
      return createElement(ValidatorSearcherBtnTemplate)
    }
  })
})
