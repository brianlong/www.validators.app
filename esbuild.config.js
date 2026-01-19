const esbuild = require('esbuild')
const path = require('path')
const vuePlugin = require('esbuild-vue')

const entryPoints = [
  {
    in: 'app/javascript/application.js',
    out: 'application'
  },
  {
    in: 'app/javascript/packs/ping_things/stats_bar.js',
    out: 'ping_things/stats_bar'
  },
  {
    in: 'app/javascript/packs/sol_prices/historical_sol_prices_component.js', 
    out: 'sol_prices/historical_sol_prices_component'
  },
  {
    in: 'app/javascript/packs/sol_prices/sol_price_component.js',
    out: 'sol_prices/sol_price_component'
  },
  {
    in: 'app/javascript/packs/epochs/epoch_stats_component.js',
    out: 'epochs/epoch_stats_component'
  },
  {
    in: 'app/javascript/packs/clusters/cluster_numbers_component.js',
    out: 'clusters/cluster_numbers_component'
  },
  {
    in: 'app/javascript/packs/clusters/cluster_performance_stats_component.js',
    out: 'clusters/cluster_performance_stats_component'
  },
  {
    in: 'app/javascript/packs/software_versions/software_versions_component.js',
    out: 'software_versions/software_versions_component'
  },
  {
    in: 'app/javascript/packs/navigations/network_buttons.js',
    out: 'navigations/network_buttons'
  },
  {
    in: 'app/javascript/packs/validators/circulating_supply.js',
    out: 'validators/circulating_supply'
  },
  {
    in: 'app/javascript/packs/transactions/transactions_stats_component.js',
    out: 'transactions/transactions_stats_component'
  },
  {
    in: 'app/javascript/packs/validators/validators_map.js',
    out: 'validators/validators_map'
  },
  {
    in: 'app/javascript/packs/navigations/validator_searcher_bar.js',
    out: 'navigations/validator_searcher_bar'
  },
  {
    in: 'app/javascript/packs/navigations/validator_searcher_btn.js',
    out: 'navigations/validator_searcher_btn'
  },
  {
    in: 'app/javascript/packs/validators/validator_details.js',
    out: 'validators/validator_details'
  },
  {
    in: 'app/javascript/packs/data_centers/map_component.js',
    out: 'data_centers/map_component'
  },
  {
    in: 'app/javascript/packs/data_centers/data_center_charts.js',
    out: 'data_centers/data_center_charts'
  },
  {
    in: 'app/javascript/packs/account_authority_histories/index.js',
    out: 'account_authority_histories/index'
  },
  {
    in: 'app/javascript/packs/stake_accounts/index.js',
    out: 'stake_accounts/index'
  },
  {
    in: 'app/javascript/packs/commission_histories/index.js',
    out: 'commission_histories/index'
  },
  {
    in: 'app/javascript/packs/ping_things/index.js',
    out: 'ping_things/index'
  },
  {
    in: 'app/javascript/packs/policies/policy.js',
    out: 'policies/policy'
  },
  {
    in: 'app/javascript/packs/policies/policies_index.js',
    out: 'policies/policies_index'
  },
  {
    in: 'app/javascript/packs/validators/components/validator_score_modal.js',
    out: 'validators/components/validator_score_modal'
  }
]

console.log('Building entry points:', entryPoints.map(ep => ep.out))

//const isProduction = process.env.NODE_ENV === 'production'
const isDev = process.env.NODE_ENV === 'development'

const buildOptions = {
  entryPoints: entryPoints,
  bundle: true,
  outdir: 'app/assets/builds',
  sourcemap: isDev,
  format: 'esm',
  target: ['es2017'],
  publicPath: '/assets',
  alias: {
    'vue/dist/vue.esm': path.resolve(__dirname, 'node_modules/vue/dist/vue.esm.js'),
    'vue': path.resolve(__dirname, 'node_modules/vue/dist/vue.esm.js')
  },
  resolveExtensions: ['.js', '.ts', '.jsx', '.tsx', '.vue'],
  plugins: [
    vuePlugin(),
    {
      name: 'asset-resolver',
      setup(build) {
        // Resolve image imports to app/assets/images/
        build.onResolve({ filter: /\.(png|jpg|jpeg|gif|svg)$/ }, args => {
          return {
            path: path.resolve('app/assets/images', args.path),
            namespace: 'file'
          }
        })
      }
    }
  ],
  loader: {
    '.png': 'file',
    '.jpg': 'file', 
    '.jpeg': 'file',
    '.gif': 'file',
    '.svg': 'file'
  },
  define: {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
    '__VUE_PROD_DEVTOOLS__': 'false',
    '__VUE_OPTIONS_API__': 'true',
    '__VUE_PROD_HYDRATION_MISMATCH_DETAILS__': 'false'
  }
}

if (isDev) {
  esbuild.context(buildOptions).then(ctx => {
    ctx.watch()
    console.log('👀 Watching for changes...')
  }).catch((e) => {
    console.error(e)
    process.exit(1)
  })
} else {
  esbuild.build(buildOptions).catch((e) => {
    console.error(e)
    process.exit(1)
  })
}
