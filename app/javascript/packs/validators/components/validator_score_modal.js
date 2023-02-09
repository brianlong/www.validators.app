import Vue from "vue/dist/vue.esm"
import TurbolinksAdapter from "vue-turbolinks"
import store from "../../stores/main_store.js"
import ValidatorScoreModal from "./validator_score_modal.vue"

Vue.use(TurbolinksAdapter)

document.addEventListener("turbolinks:load", () => {
  window.scores_modal = new Vue({
    el: "#validator-score-modal",
    store,
    render(createElement) {
      return createElement(ValidatorScoreModal, {

      })
    }
  })
})
