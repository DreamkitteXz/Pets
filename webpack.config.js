const path = require('path');
const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');

/** @type {import("next").NextConfig} */
module.exports = {
  mode: 'development',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
  },
  experimental: { appDir: true },
  webpack(config) {
    config.experiments = { ...config.experiments, topLevelAwait: true };
    config.module.rules.push({
      test: /\.(js|jsx)$/,
      exclude: /node_modules/,
      use: {
        loader: "babel-loader",
        options: {
          presets: ["@babel/preset-env", "@babel/preset-react"]
        }
      }
    });
    config.resolve.extensions.push('.jsx');
    return config;
  },
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx']
  },
  module: {
    rules: [
      {
        test: /\.[jt]sx?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: [
                '@babel/preset-env',
                ['@babel/preset-react', { runtime: 'automatic' }]
              ],
              plugins: ['react-refresh/babel']
            }
          }
        ]
      }
    ]
  },
  plugins: [new ReactRefreshWebpackPlugin()]
}