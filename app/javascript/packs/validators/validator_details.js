import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks';
import ValidatorDetails from './validator_details.vue';
import store from "../stores/main_store.js";
import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#validator-details',
    store,
    render(createElement) {
      return createElement(ValidatorDetails, {
        props: {
          account: this.$el.attributes.account.value,
        }
      })
    }
  })
})
