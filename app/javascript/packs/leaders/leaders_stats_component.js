import Vue from 'vue/dist/vue.esm'
import LeadersStatsComponentTemplate from './leaders_stats_component_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  new Vue({
    el: '#leaders-stats-component',
    render(createElement) {
      return createElement(LeadersStatsComponentTemplate);
    }
  })
})
