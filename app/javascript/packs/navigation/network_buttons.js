import Vue from 'vue/dist/vue.esm'
import NetworkButtonsTemplate from './network_buttons_template'
import TurbolinksAdapter from 'vue-turbolinks';

import WalletMultiButton from 'solana-wallets-vue-2/src/components/WalletMultiButton.vue';
// import 'solana-wallets-vue-2/styles.css'

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  const chindex = new Vue({
    el: '#network-buttons',
    render(createElement) {
      return createElement(NetworkButtonsTemplate)
    },
    components: { WalletMultiButton }
  })
})
