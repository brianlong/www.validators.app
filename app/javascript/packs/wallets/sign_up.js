import Vue from 'vue/dist/vue.esm'
import SignUpTemplate from './sign_up_template'
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#sign-up-wallet',
    render(createElement) {
      return createElement(SignUpTemplate)
    }
  })
})
