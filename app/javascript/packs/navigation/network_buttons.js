import Vue from 'vue/dist/vue.esm'
import NetworkButtonsTemplate from './network_buttons_template'

document.addEventListener('DOMContentLoaded', () => {
  const chindex = new Vue({
    el: '#network-buttons',    
    render(createElement) {
      return createElement(NetworkButtonsTemplate)
    }
  })
})