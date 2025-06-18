import Vue from 'vue/dist/vue.esm'
import PoliciesIndexTemplate from './policies_index_template'
import TurbolinksAdapter from 'vue-turbolinks';
import store from "../stores/main_store.js";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#policies-index-component',
    store,
    render(createElement) {
      return createElement(PoliciesIndexTemplate)
    }
  })
})
