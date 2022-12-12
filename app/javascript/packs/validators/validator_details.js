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
          validator: JSON.parse(this.$el.attributes.validator.value),
          score: JSON.parse(this.$el.attributes.score.value),
          root_blocks: JSON.parse(this.$el.attributes.root_blocks.value),
          vote_blocks: JSON.parse(this.$el.attributes.vote_blocks.value),
          skipped_slots: JSON.parse(this.$el.attributes.skipped_slots.value),
          block_histories: JSON.parse(this.$el.attributes.block_histories.value),
          block_history_stats: JSON.parse(this.$el.attributes.block_history_stats.value)
        }
      })
    }
  })
})
