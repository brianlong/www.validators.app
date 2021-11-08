<template>
  <div class="card mb-4">
    <div class="table-responsive-lg">
      <table class='table mb-0'>
        <thead>
          <tr>
            <th class="column-xl align-middle">
              <a href="#" @click.prevent="sort_by_stake">Stake</a>
            </th>

            <th class="column-md align-middle">
              Stake Account
              <br>
              <a href="#" @click.prevent="sort_by_staker">Staker</a>
            </th>
            <th class="column-md align-middle">
              <a href="#" @click.prevent="sort_by_withdrawer">Withdrawer</a>
            </th>
            <th>
              <a href="#" @click.prevent="sort_by_epoch">Activation Epoch</a>
            </th>
          </tr>
        </thead>
        <tbody>
          <stake-account-row v-for="sa in stake_accounts" :key="sa.id" :stake_account="sa">
          </stake-account-row>
        </tbody>
      </table>
      <div class="pt-2 px-3">
        <b-pagination
            v-model="page"
            :total-rows="total_count"
            :per-page="25"
            first-text="« First"
            last-text="Last »" />
        <!-- <a href='#'
           @click.prevent="reset_filters"
           :style="{visibility: resetFilterVisibility() ? 'visible' : 'hidden'}"
           id='reset-filters'
           class='btn btn-sm btn-primary mr-2 mb-3 mb-lg-0'>Reset filters</a> -->
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['query', 'network'],
    data () {
      var api_url = '/api/v1/stake-accounts/' + this.network
      return {
        stake_accounts: [],
        page: 1,
        total_count: 0,
        sort_by: 'epoch_desc',
        api_url: api_url,
      }
    },
    created () {
      var ctx = this
      var query_params = { params: { sort_by: ctx.sort_by, page: ctx.page } }

      axios.get(ctx.api_url, query_params)
      .then(function (response){
        ctx.stake_accounts = response.data.stake_accounts;
        ctx.total_count = response.data.total_count;
      })
    },
    watch: {
      sort_by: function(){
        var ctx = this
        var query_params = { params: { sort_by: ctx.sort_by, page: ctx.page } }

        axios.get(ctx.api_url, query_params)
             .then(function (response) {
               ctx.stake_accounts = response.data.stake_accounts;
               ctx.total_count = response.data.total_count;
             })
      },
      page: function(){
        this.paginate()
      }
    },
    methods: {
      paginate: function(){
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page

        axios.get(url)
             .then(response => (
               ctx.commission_histories = response.data.commission_histories
             ))
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
      reset_filters: function() {
        console.log('reset filters')
      },
    }
  }
</script>
