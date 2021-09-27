import Vue from 'vue/dist/vue.esm'
import NetworkButtonsTemplate from './network_buttons_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#network-buttons',
    render(createElement) {
      return createElement(NetworkButtonsTemplate)
    }
  })
})