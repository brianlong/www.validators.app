import Vue from 'vue/dist/vue.esm'
import IndexTemplate from './index_template'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.component('BPagination', BPagination)
Vue.use(PaginationPlugin);

document.addEventListener('DOMContentLoaded', () => {
  const ping_thing_index = new Vue({
    el: '#ping-thing-index-vue',    
    render(createElement) {
      return createElement(IndexTemplate, {
        props: {
          network: this.$el.attributes.network ? this.$el.attributes.network.value : 'mainnet'
        }
      })
    },
    component: {
      'BPagination': BPagination
    }
  })
})
