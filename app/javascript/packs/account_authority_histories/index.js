import Vue from "vue/dist/vue.esm"
import IndexTemplate from './index_template'
import TurbolinksAdapter from "vue-turbolinks"
import store from "../stores/main_store.js"
import * as AuthorizedVoters from "./authorized_voters"
import * as AuthorizedWithdrawer from "./authorized_withdrawer"

Vue.use(TurbolinksAdapter)

document.addEventListener("turbolinks:load", () => {
  new Vue({
    el: "#authority-histories",
    store,
    render(createElement) {
      return createElement(IndexTemplate, {
        props: {
          vote_account: this.$el.attributes.vote_account ? this.$el.attributes.vote_account.value : null
        }
      })
    },
    component: {
      'AuthorizedVoters': AuthorizedVoters,
      'AuthorizedWithdrawer': AuthorizedWithdrawer
    }
  })
})
