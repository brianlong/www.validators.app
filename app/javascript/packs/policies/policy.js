import Vue from 'vue/dist/vue.esm'
import PolicyTemplate from './policy_template'
import ValidatorRow from '../validators/validator_row'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";

Vue.use(TurbolinksAdapter);
Vue.use(PaginationPlugin);

document.addEventListener('turbolinks:load', () => {
  const policy = new Vue({
    el: '#policy-component',
    store,
    render(createElement) {
      return createElement(PolicyTemplate, {
        props: {
          pubkey: this.$el.getAttribute('pubkey')
        }
      })
    },

    components: {
      "ValidatorRow": ValidatorRow,
      'BPagination': BPagination
    }
  })
})

