<template>
  <div class="card mb-4">
    <div class="table-responsive-lg">
      <table class='table mb-0'>
        <thead>
          <tr>
            <th class="narrower-column">
              <a href="#" @click.prevent="sort_by_validator">Validator</a>
            </th>
            <th class="narrower-column">
              <a href="#" @click.prevent="sort_by_epoch">Epoch</a><br />
              <small>(completion %)</small>
            </th>
            <th class="wider-column">Batch</th>
            <th class="wider-column text-center">Before<i class="fas fa-long-arrow-alt-right px-2"></i>After</th>
            <th class="narrower-column">
              <a href="#" @click.prevent="sort_by_timestamp">Timestamp</a>
            </th>
          </tr>
        </thead>
        <tbody>
          <commission-history-row v-for="ch in commission_histories" :key="ch.id" :chistory="ch">
          </commission-history-row>
        </tbody>
      </table>
      <div class="pt-2 px-3">
        <b-pagination
            v-model="page"
            :total-rows="total_count"
            :per-page="25"
            first-text="« First"
            last-text="Last »" />
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
      if(this.query && !this.query == ''){
        var api_url = '/api/v1/commission-changes/' + this.network + '?query=' + this.query + '&'
      } else {
        var api_url = '/api/v1/commission-changes/' + this.network + '?'
      }
      return {
        commission_histories: [],
        page: 1,
        total_count: 0,
        sort_by: 'created_at_desc',
        api_url: api_url
      }
    },
    created () {
      var ctx = this
      axios.get(this.api_url + 'sort_by=' + ctx.sort_by)
      .then(function (response){
        ctx.commission_histories = response.data.commission_histories;
        ctx.total_count = response.data.total_count;
      })
    },
    watch: {
      sort_by: function(){
        var ctx = this
        axios.get(this.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page)
        .then(function (response){
          ctx.commission_histories = response.data.commission_histories;
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
        axios.get(this.api_url + 'sort_by=' + ctx.sort_by + '&page=' + ctx.page)
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
    }
  }
</script>