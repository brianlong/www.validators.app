
var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: [
    'babel-polyfill',
    './app-js/main',
  ],
  output: {
    path: __dirname + '/app/assets/javascripts',
    filename: 'app-js.js'
  },
  module: {
    loaders: [
      {
        include: path.join(__dirname, 'app-js'),
        loader: 'babel-loader',
        query: {
          presets: ['es2015']
        }
      }
    ]
  },
  "transform": {
    "^.+\\.[t|j]sx?$": "babel-jest"
  },
};
