var path = require('path');
var webpack = require('webpack');
var HtmlPlugin = require('html-webpack-plugin');
var CopyPlugin = require('copy-webpack-plugin');

const buildPath = './dist';
const publicPath = '/';

module.exports = {
  entry: './src/renderer.js',
  output: {
    path: buildPath,
    filename: 'app.js',
    publicPath: publicPath
  },
  plugins: [
    new HtmlPlugin(),
    new CopyPlugin([
      { from: './src/main.js' },
      { from: './static/chilicornie.png' }
    ]),
    new webpack.HotModuleReplacementPlugin()
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
  },
  devServer: {
    publicPath: publicPath,
    contentBase: buildPath,
    clientLogLevel: 'none',
    noInfo: true,
    hot: true,
    inline: true,
    port: 3000
  }
};
