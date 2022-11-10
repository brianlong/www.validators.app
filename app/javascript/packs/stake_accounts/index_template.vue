<template>
  <div class="row">
    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <div class="card-heading">
            <h2 class="h4 mb-2">Filter by Stake Pool</h2>
            <small class="text-muted">Click on stake pool logo to see pool stats</small>
          </div>

          <div class="row text-center" v-if="!is_loading_stake_pools">
            <a class="col-6 col-xl-4"
               v-for="pool in stake_pools"
               :key="pool.id"
               href="#"
               title="Filter by Stake Pool"
               @click.prevent="filter_by_withdrawer(pool)"
            >
              <img class="img-link w-100 px-2 px-lg-3 px-lx-2 py-4 py-md-3 py-xl-4" v-bind:src="pool_images[pool.name.toLowerCase()]">
            </a>
          </div>
        </div>

        <div v-if="is_loading_stake_pools" class="text-center my-5">
          <img v-bind:src="loading_image" width="100">
        </div>
      </div>
    </div>

    <!-- Form -->
    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <div class="mb-3">
            <label class="form-label">Withdrawer</label>
            <input v-model="filter_withdrawer" type="text" class="form-control">
          </div>
          <div class="mb-3">
            <label class="form-label">Validator</label>
            <input v-model="filter_validator" type="text" class="form-control">
          </div>
          <div class="mb-3">
            <label class="form-label">Stake account</label>
            <input v-model="filter_account" type="text" class="form-control">
          </div>
          <div class="mb-4">
            <label class="form-label">Staker</label>
            <input v-model="filter_staker" type="text" class="form-control">
          </div>
          <a href="#" v-if="filters_present()" @click.prevent="reset_filters" class="btn btn-sm btn-tertiary">
            Reset filters
          </a>
        </div>
      </div>
    </div>

    <!-- Stake pools overview -->
    <div class="col-12 mb-4" v-if="!selected_pool && !is_loading_stake_pools">
      <stake-pools-overview
        :stake_pools="stake_pools"
        @filter_by_withdrawer="filter_by_withdrawer"
      />
    </div>

    <!-- Stake pool stats -->
    <div class="col-12 mb-4" v-if="selected_pool && !is_loading_stake_pools">
      <stake-pool-stats :pool="selected_pool"/>
    </div>

    <!-- Validators and accounts table -->
    <div class="col-12" v-if="!is_loading_stake_accounts && !is_loading_stake_pools">
      <div class="card">
        <table class="table table-block-sm validators-table">
          <thead>
            <tr>
              <th class="column-info">
                <div class="column-info-row">
                  <div class="column-info-name">
                    Name <small class="text-muted">(Commission)</small>
                    <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                       data-bs-toggle="tooltip"
                       data-bs-placement="top"
                       title="Commission is the percent of network rewards earned by a validator that are deposited into the validator's vote account.">
                    </i>
                    <br />
                    Scores <small class="text-muted">(total)</small>
                    <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                       data-bs-toggle="tooltip"
                       data-bs-placement="top"
                       title="Our score system.">
                    </i>
                  </div>
                </div>
              </th>

              <th class='column-speedometer pe-0'>
                Skipped Vote
                <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Skipped vote measures the percent of the time that a leader fails to vote.">
                </i>
                <br />
                <small class="text-muted">Dist from leader</small>
              </th>

              <th class='column-chart py-3'>
                Root Distance
                <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Root distance measures the median & average distance in block height between the validator and the tower's highest block. Smaller numbers mean that the validator is near the top of the tower.">
                </i>
                <br />
                <small class="text-muted">60-Min Chart</small>
              </th>

              <th class='column-chart py-3'>
                Vote Distance
                <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Vote distance is very similar to the Root Distance. Lower numbers mean that the node is voting near the front of the group.">
                </i>
                <br />
                <small class="text-muted">60-Min Chart</small>
              </th>

              <th class='column-chart py-3'>
                Skipped Slot&nbsp;&percnt;
                <i class="fas fa-info-circle font-size-xs text-muted ms-1"
                   data-bs-toggle="tooltip"
                   data-bs-placement="top"
                   title="Skipped slot measures the percent of the time that a leader fails to produce a block during their allocated slots. A lower number means that the leader is making blocks at a very high rate.">
                </i>
                <br />
                <small class="text-muted">60-Min Chart</small>
              </th>
            </tr>
          </thead>

          <stake-account-row
            v-for="(sa, index) in stake_accounts"
            :key="sa.id"
            :stake_accounts="sa"
            :idx="index + (page - 1) * 20"
            :batch="batch"
            :current_epoch="current_epoch"
          >
          </stake-account-row>
        </table>

        <div class="card-footer">
          <b-pagination
              v-model="page"
              :total-rows="total_count"
              :per-page="20"
              first-text="« First"
              last-text="Last »" />
        </div>
      </div>
    </div>

    <div v-if="is_loading_stake_accounts && is_loading_stake_pools" class="col-12 text-center my-5">
      <img v-bind:src="loading_image" width="100">
    </div>

    <section class="mt-5" id="metrics">
      <h2>Metrics Explanation</h2>
      <hr />
      <h3 class="h5">Nodes total</h3>
      <p class="mb-5">
        Number of validators used by the stake pool. Bigger validator diversity helps to maintain good network health.
      </p>

      <h3 class="h5">Nodes Delinquent</h3>
      <p class="mb-5">
        Number of delinquent validators used by the stake pool.
      </p>

      <h3 class="h5">Nodes Stake</h3>
      <p class="mb-5">
        Total stake of the stake pool divided among the validators.
      </p>

      <h3 class="h5">Avg Stake</h3>
      <p class="mb-5">
        Average stake that the pool delegates to a single validator.
      </p>

      <h3 class="h5">Manager Fee</h3>
      <p class="mb-5">
        Commission that stake pool substracts from the total profit to maintain their operation.
      </p>

      <h3 class="h5">Deposit Fee</h3>
      <p class="mb-5">
        Fee paid while depositing new stake to the stake pool.
      </p>

      <h3 class="h5">Withdrawal Fee</h3>
      <p class="mb-5">
        Fee paid while withdrawing any amount of stake from the stake pool.
      </p>

      <h3 class="h5">Avg Validators Fee</h3>
      <p class="mb-5">
        Average commission of all the validators used by the stake pool. See
        <a href="/faq#commission" target="_blank">what is validator commission?</a>
      </p>

      <h3 class="h5">APY</h3>
      <p>
        <strong>Annual Percentage Yield</strong> - rate of return from delegating to a stake pool. It is the weighted average of the APY's
        from all the validators reduced by the <strong>manager fee</strong>. Validators weight is proportional to the active_stake of the accounts.<br />
        APY of the validator is calculated as follows:
      </p>
      <p>
        <strong> ((1 + rewards_percent) ^ number_of_epochs_per_year) - 1 </strong>
      </p>
      <p>
        Where number_of_epochs_per_year is calculated as follows:
        <strong>seconds_in_year / duration_of_last_epoch_in_seconds</strong><br />
        This gives the number of epochs in a year assuming all epochs were as long as the last epoch.
      </p>
      <p class="mb-5">
        And <strong>rewards_percent</strong> is the interest rate of validator, based on the reward from the last epoch.
      </p>

      <h3 class="h5">Avg Skipped Slot</h3>
      <p class="mb-5">
        Average skipped slot of all the validators used by the stake pool. See
        <a href="/faq#skipped-vote" target="_blank">what is validator skipped slot?</a>
      </p>

      <h3 class="h5">Avg Lifetime</h3>
      <p class="mb-5">
        Average number of days since each validator from the stake pool was created.
      </p>

      <h3 class="h5">Avg Uptime</h3>
      <p class="mb-5">
        Average number of days each validator operates continuously without shutting down.
      </p>

      <h3 class="h5">Avg Score</h3>
      <p class="mb-5">
        Average score of the validators from the stake pool. See
        <a href="/faq#score" target="_blank">how are scores calculated?</a>
      </p>

      <h3 class="h5">Stake Account Activation Epoch</h3>
      <p>
        Number of epoch in which the account was first activated.
      </p>
    </section>
  </div>
</template>

<script>
  import axios from 'axios'
  import loadingImage from 'loading.gif'

  import marinadeImage from 'marinade.png'
  import soceanImage from 'socean.png'
  import lidoImage from 'lido.png'
  import jpoolImage from 'jpool.png'
  import daopoolImage from 'daopool.png'
  import eversolImage from 'eversol.png'
  import blazestakeImage from 'blazestake.png'
  import jitoImage from 'jito.png'

  import debounce from 'lodash/debounce'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['query', 'network'],
    data () {
      var stake_accounts_api_url = '/api/v1/stake-accounts/' + this.network
      var stake_pools_api_url = '/api/v1/stake-pools/' + this.network

      return {
        stake_accounts: [],
        page: 1,
        total_count: 0,
        sort_by: 'epoch_desc',
        stake_accounts_api_url: stake_accounts_api_url,
        stake_pools_api_url: stake_pools_api_url,
        filter_withdrawer: null,
        filter_staker: null,
        filter_account: null,
        filter_validator: null,
        is_loading_stake_accounts: true,
        is_loading_stake_pools: true,
        stake_pools: null,
        selected_pool: null,
        batch: null,
        current_epoch: null,
        loading_image: loadingImage,
        seed: Math.floor(Math.random() * 1000),
        pool_images: {
          marinade: marinadeImage,
          socean: soceanImage,
          lido: lidoImage,
          jpool: jpoolImage,
          daopool: daopoolImage,
          eversol: eversolImage,
          blazestake: blazestakeImage,
          jito: jitoImage
        }
      }
    },
    created () {
      var ctx = this
      var stake_accounts_query_params = {
        params: {
          sort_by: ctx.sort_by,
          page: ctx.page,
          with_batch: true,
          seed: ctx.seed,
          grouped_by: 'delegated_vote_accounts_address'
        }
      }

      axios.get(ctx.stake_accounts_api_url, stake_accounts_query_params)
           .then(function (response){
             ctx.stake_accounts = response.data.stake_accounts
             ctx.total_count = response.data.total_count;
             ctx.is_loading_stake_accounts = false;
             ctx.current_epoch = response.data.current_epoch
             ctx.batch = response.data.batch
           })

      axios.get(ctx.stake_pools_api_url)
           .then(function (response){
             ctx.stake_pools = response.data.stake_pools.sort((a, b) => 0.5 - Math.random());
             ctx.is_loading_stake_pools = false
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
      refresh_results: debounce(function() {
        var ctx = this

        ctx.is_loading_stake_accounts = true

        var query_params = {
          params: {
            sort_by: ctx.sort_by,
            page: ctx.page,
            filter_account: ctx.filter_account,
            filter_staker: ctx.filter_staker,
            filter_withdrawer: ctx.filter_withdrawer,
            filter_validator: ctx.filter_validator,
            grouped_by: 'delegated_vote_accounts_address',
            seed: ctx.seed
          }
        }

        axios.get(ctx.stake_accounts_api_url, query_params)
             .then(function (response) {
               ctx.stake_accounts = response.data.stake_accounts;
               ctx.total_count = response.data.total_count;
               ctx.current_epoch = response.data.current_epoch;
               ctx.is_loading_stake_accounts = false;
             })
      }, 2000),
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
      filter_by_withdrawer: function(pool){
        this.filter_withdrawer = pool.authority
        this.selected_pool = pool
      },
      reset_filters: function() {
        this.filter_withdrawer = null
        this.filter_staker = null
        this.filter_account = null
        this.filter_validator = null
        this.selected_pool = null
      },
      filters_present: function(){
        return this.filter_withdrawer || this.filter_staker || this.filter_account || this.filter_validator
      }
    }
  }
</script>
