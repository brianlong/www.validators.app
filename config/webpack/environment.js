// ##############################
// webpack/environment.js
// ##############################

const { environment } = require('@rails/webpacker')
const path = require('path')
const { DefinePlugin } = require('webpack')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require("./loaders/vue");

const customConfig = {
  resolve:{
    alias: {
      "@": path.resolve(__dirname, "..", "..", "app/javascript/src"),
      vue: 'vue/dist/vue.esm-bundler.js'
    }
  }
}

environment.config.merge(customConfig)

environment.plugins.prepend(
    'VueLoaderPlugin',
    new VueLoaderPlugin()
)

environment.plugins.prepend(
    'Define',
    new DefinePlugin({
        __VUE_OPTIONS_API__: false,
        // or __VUE_OPTIONS_API__: true,
        __VUE_PROD_DEVTOOLS__: false
    })
)

environment.loaders.prepend('vue', vue)

module.exports = environment