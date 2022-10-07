module.exports = {
  test: /\.vue(\.erb)?$/,
  use: [{
    loader: 'vue-loader'
  }],
  devServer: {
    proxy: 'https://www.validators.app',
  }
}
