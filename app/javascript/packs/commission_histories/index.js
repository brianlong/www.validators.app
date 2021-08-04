import Vue from 'vue/dist/vue.esm'
import App from '../../app.vue'
import IndexTemplate from './index_template'
import axios from 'axios'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#commission-histories-index-vue',
    render: h => h(IndexTemplate),
  })
})
