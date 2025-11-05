// Główny Vue bundle - eksportuje Vue globalnie
import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'

Vue.use(BootstrapVue)

// Eksportuj Vue globalnie
window.Vue = Vue

export default Vue
