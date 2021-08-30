module.exports = {
  resolve: {
    extensions: settings.extensions,
    modules: [
      resolve(settings.source_path),
      'node_modules'
    ],
    alias: {
      vue$: 'vue/dist/vue.common.js'
    }
  },
}
