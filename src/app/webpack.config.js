const fs = require('fs');
const path = require('path');
const webpack = require('webpack');

const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const StyleLintPlugin = require('stylelint-webpack-plugin');
const HtmlWebpackInlineSourcePlugin = require('html-webpack-inline-source-plugin');
const TerserPlugin = require('terser-webpack-plugin');

const config = {
  entry: './src/js/main.js',
  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'build'),
    library: 'speakJS'
  },
  plugins: [
    new CleanWebpackPlugin(),
    new StyleLintPlugin({
      context: './src/sass',
      fix: true,
    }),
    new HtmlWebpackPlugin({
      template: 'src/index.html',
      inlineSource: '.(js|css)$'
    }),
    new HtmlWebpackInlineSourcePlugin(),
    compiler => {
      compiler.hooks.done.tap('Copy build files to Lua', () => {
        const bundle = fs.readFileSync('build/index.html');

        try {
          fs.writeFileSync(
            path.resolve(__dirname, 'dist/bundle.lua'),
`speak.bundle = [==[${bundle}]==]

if IsValid(speak.view) then
  speak.view:Refresh()
end
`
          );
          fs.writeFileSync(
            path.resolve(__dirname, 'dist/version.lua'),
            `return "${process.env.REACT_APP_GIT_COMMIT}"`
          );
        } catch(err) {
          console.log(err);
        }
      });
    },
    new webpack.ProgressPlugin()
  ],
  module: {
    rules: [
      {
        test: /\.html$/,
        use: 'html-loader'
      },
      {
        test: /\.css$|\.scss$/,
        use: [
          'style-loader',
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.svg$/,
        use: 'url-loader'
      }
    ]
  },
  optimization: {
    moduleIds: 'hashed',
    runtimeChunk: 'single',
    splitChunks: {
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        },
      },
    },
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          mangle: false,
          keep_classnames: true,
          keep_fnames: true
        }
      })
    ]
  }
};

module.exports = config;
