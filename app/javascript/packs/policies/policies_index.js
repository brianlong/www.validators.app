import Vue from 'vue/dist/vue.esm'
import PoliciesIndexTemplate from './policies_index_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.use(TurbolinksAdapter);
Vue.use(PaginationPlugin);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#policies-index-component',
    store,
    render(createElement) {
      return createElement(PoliciesIndexTemplate)
    },
    components: {
      'BPagination': BPagination
    }
  })
})
