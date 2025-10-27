import Vue from '../shared/vue_setup'
import TurbolinksAdapter from 'vue-turbolinks';
import ValidatorDetails from './validator_details.vue';
import ActionCableVue from "actioncable-vue";

Vue.use(TurbolinksAdapter);
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: "error",
  connectionUrl: "/cable",
  connectImmediately: true,
});

document.addEventListener('turbolinks:load', () => {
  if (document.getElementById('validator-details') && window.globalStore) {
    new Vue({
      el: '#validator-details',
      store: window.globalStore,
      render(createElement) {
        return createElement(ValidatorDetails, {
          props: {
            account: this.$el.attributes.account.value,
          }
        })
      }
    })
  }
})
