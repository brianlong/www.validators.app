import Vue from '../shared/vue_setup'
import IndexTemplate from './index_template'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import ActionCableVue from "actioncable-vue";
import store from "../stores/main_store.js";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

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
