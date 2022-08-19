const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const webpack = require('webpack')

environment.loaders.get('nodeModules').exclude = /(?:@?babel(?:\/|\\{1,2}|-).+)|regenerator-runtime|core-js|webpack/;
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
// TODO to remove
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)
environment.loaders.prepend('vue', vue)

const resolver = {
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  }
}
environment.config.merge(resolver)
module.exports = environment
