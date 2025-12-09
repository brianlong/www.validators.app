import Vue from '../shared/vue_setup'
import NetworkButtonsTemplate from './network_buttons_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

Vue.directive('click-outside', {
  bind: function (el, binding, vnode) {
    el.clickOutsideEvent = function (event) {
      // here I check that click was outside the el and his children
      if (!(el == event.target || el.contains(event.target))) {
        // and if it did, call method provided in attribute value
        vnode.context[binding.expression](event);
      }
    };
    document.body.addEventListener('click', el.clickOutsideEvent)
  },
  unbind: function (el) {
    document.body.removeEventListener('click', el.clickOutsideEvent)
  },
});

document.addEventListener('turbolinks:load', () => {
  if (document.getElementById('network-buttons')) {
    if (!window.globalStore) {
      console.error('globalStore not available for network-buttons')
      return
    }
    
    new Vue({
      el: '#network-buttons',
      store: window.globalStore,
      render(createElement) {
        return createElement(NetworkButtonsTemplate)
      }
    })
  }
})
