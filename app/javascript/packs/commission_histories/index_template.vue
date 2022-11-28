<template>
  <div class="card mb-4">
    <div class="table-responsive-lg">
      <table class='table'>
        <thead>
          <tr>
            <th class="column-xl">
              <a href="#" @click.prevent="sort_by_validator">Validator</a>
            </th>
            <th class="column-md">
              <a href="#" @click.prevent="sort_by_epoch">Epoch</a><br />
              <small class="text-muted">(completion %)</small>
            </th>
            <th class="column-md">Batch</th>
            <th class="column-lg text-center px-2">
              Before<i class="fas fa-long-arrow-alt-right px-2"></i>After
            </th>
            <th class="column-md">
              <a href="#" @click.prevent="sort_by_timestamp">Timestamp</a>
            </th>
          </tr>
        </thead>
        <tbody>
          <commission-history-row @filter_by_query="filter_by_query" v-for="ch in commission_histories" :key="ch.id" :comm_history="ch">
          </commission-history-row>
        </tbody>
      </table>
    </div>

    <div class="card-footer d-flex justify-content-between flex-wrap gap-2">
      <b-pagination
          v-model="page"
          :total-rows="total_count"
          :per-page="25"
          first-text="« First"
          last-text="Last »" />
      <a href='#'
         @click.prevent="reset_filters"
         :style="{display: resetFilterVisibility() ? '' : 'none'}"
         id='reset-filters'
         class='btn btn-sm btn-tertiary'>Reset filters</a>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex';

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['query'],
    data () {
      return {
        commission_histories: [],
        page: 1,
        total_count: 0,
        sort_by: 'created_at_desc',
        api_url: null,
        account_name: this.query
      }
    },
    created () {
      if (this.query) {
        this.api_url = '/api/v1/commission-changes/' + this.network + '?query=' + this.query + '&'
      } else {
        this.api_url = '/api/v1/commission-changes/' + this.network + '?'
      }
      var ctx = this
      var url = ctx.api_url + 'sort_by=' + ctx.sort_by

      axios.get(url)
      .then(function (response){
        ctx.commission_histories = response.data.commission_histories;
        ctx.total_count = response.data.total_count;
      })
    },
    watch: {
      sort_by: function(){
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page

        if (ctx.checkAccountNamePresence())  {
          url = url + '&query=' + ctx.account_name
        }

        axios.get(url)
             .then(function (response) {
               ctx.commission_histories = response.data.commission_histories;
               ctx.total_count = response.data.total_count;
             })
      },
      page: function(){
        this.paginate()
      },
      account_name: function() {
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + 1 + '&query=' + ctx.account_name

        axios.get(url)
             .then(function (response) {
                ctx.commission_histories = response.data.commission_histories;
                ctx.total_count = response.data.total_count;
              })
      }
    },
    computed: mapGetters([
      'network'
    ]),
    methods: {
      paginate: function(){
        var ctx = this
        var url = ctx.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page

        if (ctx.checkAccountNamePresence())  {
          url = url + '&query=' + ctx.account_name
        }

        axios.get(url)
             .then(response => (
               ctx.commission_histories = response.data.commission_histories
             ))
      },
      sort_by_epoch: function(){
        this.sort_by = this.sort_by == 'epoch_desc' ? 'epoch_asc' : 'epoch_desc'
      },
      sort_by_timestamp: function(){
        this.sort_by = this.sort_by == 'timestamp_asc' ? 'timestamp_desc' : 'timestamp_asc'
      },
      sort_by_validator: function(){
        this.sort_by = this.sort_by == 'validator_desc' ? 'validator_asc' : 'validator_desc'
      },
      filter_by_query: function(query) {
        this.account_name = query;
      },
      reset_filters: function() {
        this.account_name = '';
      },
      resetFilterVisibility: function() {
        // This checks if there is a account id in the link.
        var props_query = this.$options.propsData['query']

        if (this.checkAccountNamePresence() && props_query == null) {
          return true
        } else {
          return false
        }
      },
      checkAccountNamePresence: function() {
        if (this.account_name !== '' && this.account_name != undefined && this.account_name != null) {
          return true
        } else {
          return false
        }
      }
    }
  }
</script>
