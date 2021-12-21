<template>
  <div class="row">
    <div class="col-md-6 mb-3">
      <div class="card mb-3">
        <div class="card-content">
          <h3 class="card-heading mb-4">Filter by</h3>
          <div class="form-group">
            <label>Withdrawer</label>
            <input v-model="filter_withdrawer" type="text" class="form-control mb-3">
          </div>
          <div class="form-group">
            <label>Validator</label>
            <input v-model="filter_validator" type="text" class="form-control">
          </div>
          <div class="form-group">
            <label>Stake account</label>
            <input v-model="filter_account" type="text" class="form-control">
          </div>
          <div class="form-group">
            <label>Staker</label>
            <input v-model="filter_staker" type="text" class="form-control">
          </div>
          <a href="#" v-if="filters_present()" @click.prevent="reset_filters" class="btn btn-xs btn-tertiary mb-2">
            Reset filters
          </a>
        </div>
      </div>
    </div>

    <div class="col-md-6">
      <div class="card mb-3">
        <div class="card-content">
          <h3 class="card-heading mb-4">Stake Pools</h3>
        </div>
        <div class="row" v-if="!is_loading">
          <a class="col-6 text-center mb-5" 
               v-for="pool in stake_pools" 
               :key="pool.id"
               href="#"
               @click.prevent="filter_by_withdrawer(pool.authority); selected_pool = pool"
          >
            <img v-bind:src="pool_images[pool.name.toLowerCase()]" width="150">
          </a>
        </div>
        
        <div v-if="is_loading" class="text-center my-5">
          <img v-bind:src="loading_image" width="100">
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-content">
          <h3 class="card-heading mb-4">Statistics</h3>
        </div>
        <table class="table table-block-sm mb-0" v-if="!is_loading">
          <tbody>
            <tr>
              <td>Total stake: </td>
              <td>{{ (total_stake / 1000000000).toFixed(3) }} SOL</td>
            </tr>
            <tr>
              <td>Number of accounts: </td>
              <td>{{ total_count }}</td>
            </tr>
          </tbody>
        </table>
        <div v-if="is_loading" class="text-center my-5">
          <img v-bind:src="loading_image" width="100">
        </div>
      </div>
    </div>

    <div class="col-12 mb-4" v-if="selected_pool && !is_loading">
      <stake-pool-stats :pool="selected_pool" />
    </div>

    <div class="col-12" v-if="!is_loading">
      <div class="card mb-4">
        <div class="table-responsive-lg">
          <table class='table'>
            <thead>
              <tr>
                <th class="column-md align-middle">
                  <a href="#" @click.prevent="sort_by_stake">Stake</a>
                  <br>
                  Delegated validator
                </th>

                <th class="column-xl align-middle">
                  Stake Account
                  <br>
                  <a href="#" @click.prevent="sort_by_staker">Staker</a>
                </th>
                <th class="column-xl align-middle">
                  <a href="#" @click.prevent="sort_by_withdrawer">Withdrawer</a>
                </th>
                <th class="column-sm align-middle">
                  <a href="#" @click.prevent="sort_by_epoch">Activation Epoch</a>
                </th>
              </tr>
            </thead>
            <tbody>
              <stake-account-row 
                @filter_by_staker="filter_by_staker"
                @filter_by_withdrawer="filter_by_withdrawer"
                v-for="sa in stake_accounts" 
                :key="sa.id" 
                :stake_account="sa">
              </stake-account-row>
            </tbody>
          </table>
        </div>
        <b-pagination
         v-model="page"
         total-rows="total_count"
         :per-page="25"
         first-text="« First"
         last-text="Last »" />
      </div>
    </div>
    <div v-if="is_loading" class="col-12 text-center my-5">
      <img v-bind:src="loading_image" width="100">
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import loadingImage from 'loading.gif'
  import marinadeImage from 'marinade.png'
  import soceanImage from 'socean.png'
  import lidoImage from 'lido.png'
  import jpoolImage from 'jpool.png'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['query', 'network'],
    data () {
      var api_url = '/api/v1/stake-accounts/' + this.network
      return {
        stake_accounts: [],
        page: 1,
        total_count: 0,
        total_stake: 0,
        sort_by: 'epoch_desc',
        api_url: api_url,
        filter_withdrawer: null,
        filter_staker: null,
        filter_account: null,
        filter_validator: null,
        is_loading: true,
        stake_pools: null,
        selected_pool: null,
        loading_image: loadingImage,
        pool_images: {
          marinade: marinadeImage,
          socean: soceanImage,
          lido: lidoImage,
          jpool: jpoolImage
        }
      }
    },
    created () {
      var ctx = this
      var query_params = { params: { sort_by: ctx.sort_by, page: ctx.page } }

      axios.get(ctx.api_url, query_params)
           .then(function (response){
             ctx.stake_accounts = response.data.stake_accounts;
             ctx.stake_pools = response.data.stake_pools.sort((a, b) => 0.5 - Math.random());
             ctx.total_count = response.data.total_count;
             ctx.total_stake = response.data.total_stake;
             ctx.is_loading = false;
           })
    },
    watch: {
      sort_by: function(){
        this.refresh_results()
      },
      page: function(){
        this.paginate()
      },
      filter_account: function(){
        this.refresh_results()
      },
      filter_staker: function(){
        this.refresh_results()
      },
      filter_withdrawer: function(){
        this.refresh_results()
      },
      filter_validator: function(){
        this.refresh_results()
      }
    },
    methods: {
      paginate: function(){
        this.refresh_results()
      },
      refresh_results: function(){
        var ctx = this
        ctx.is_loading = true
        var query_params = { 
          params: { 
            sort_by: ctx.sort_by,
            page: ctx.page,
            filter_account: ctx.filter_account,
            filter_staker: ctx.filter_staker,
            filter_withdrawer: ctx.filter_withdrawer,
            filter_validator: ctx.filter_validator
          }
        }

        axios.get(ctx.api_url, query_params)
             .then(function (response) {
               ctx.stake_accounts = response.data.stake_accounts;
               ctx.total_count = response.data.total_count;
               ctx.total_stake = response.data.total_stake;
               ctx.is_loading = false
             })
      },
      sort_by_epoch: function(){
        this.sort_by = this.sort_by == 'epoch_desc' ? 'epoch_asc' : 'epoch_desc'
      },
      sort_by_stake: function(){
        this.sort_by = this.sort_by == 'stake_desc' ? 'stake_asc' : 'stake_desc'
      },
      sort_by_staker: function(){
        this.sort_by = this.sort_by == 'staker_desc' ? 'staker_asc' : 'staker_desc'
      },
      sort_by_withdrawer: function(){
        this.sort_by = this.sort_by == 'withdrawer_desc' ? 'withdrawer_asc' : 'withdrawer_desc'
      },
      filter_by_staker: function(staker){
        this.filter_staker = staker
      },
      filter_by_withdrawer: function(withdrawer){
        this.filter_withdrawer = withdrawer
      },
      reset_filters: function() {
        this.filter_withdrawer = null
        this.filter_staker = null
        this.filter_account = null
        this.filter_validator = null
      },
      filters_present: function(){
        return this.filter_withdrawer || this.filter_staker || this.filter_account || this.filter_validator
      }
    }
  }
</script>
