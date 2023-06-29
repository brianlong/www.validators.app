import Vue from "vue/dist/vue.esm"
import IndexTemplate from './index_template'
import TurbolinksAdapter from "vue-turbolinks"
import store from "../stores/main_store.js"
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.use(TurbolinksAdapter)
Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin)

document.addEventListener("turbolinks:load", () => {
  new Vue({
    el: "#authority-histories",
    store,
    render(createElement) {
      return createElement(IndexTemplate, {
        props: {
          vote_account: this.$el.attributes.vote_account ? this.$el.attributes.vote_account.value : null,
          standalone: this.$el.attributes.standalone ? this.$el.attributes.standalone.value : null
        }
      })
    },
    component: {
      'BPagination': BPagination
    }
  })
})
