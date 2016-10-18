var path = require('path');
var webpack = require('webpack');
var HtmlPlugin = require('html-webpack-plugin');
var CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './src/renderer.js',
  output: {
    path: './dist',
    filename: 'app.js',
    publicPath: './'
  },
  plugins: [
    new HtmlPlugin(),
    new CopyPlugin([
      { from: './src/main.js' },
      { from: './static/chilicornie.png' }
    ])
  ],
  module: {
    noParse: [/.elm$/],
    loaders: [
      {
        test: /\.elm$/,
        loaders: ['elm-hot', 'elm-webpack']
      },
      {
        test: /\.css$/,
        loaders: ['style', 'css']
      }
    ]
  }
};
