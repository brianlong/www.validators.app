import Vue from 'vue/dist/vue.esm'
import EpochStatsComponentTemplate from './epoch_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#epoch-stats-component',
    render(createElement) {
      return createElement(EpochStatsComponentTemplate)
    }
  })
})
