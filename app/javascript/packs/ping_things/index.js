import Vue from '../shared/vue_setup'
import IndexTemplate from './index_template'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import store from "../stores/main_store.js";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const ping_thing_index = new Vue({
    el: '#ping-thing-index-vue',
    store,
    render(createElement) {
      return createElement(IndexTemplate)
    },
    component: {
      'BPagination': BPagination
    }
  })
})
