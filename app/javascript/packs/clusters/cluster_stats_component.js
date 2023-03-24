import Vue from 'vue/dist/vue.esm'
import ClusterStatsTemplate from './cluster_stats_template'
import TurbolinksAdapter from 'vue-turbolinks'
import store from "../stores/main_store.js"
import EpochProgressComponent from "../epochs/epoch_progress_component"
import EpochMainComponent from "../epochs/epoch_main_component"
import ClusterNumbersComponent from "./cluster_numbers_component"

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#cluster-stats',
    store,
    render(createElement) {
      return createElement(ClusterStatsTemplate)
    },
    component: {
      'EpochProgressComponent': EpochProgressComponent,
      'EpochMainComponent': EpochMainComponent,
      'ClusterNumbersComponent': ClusterNumbersComponent
    }
  })
})
