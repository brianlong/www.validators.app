<template>
  <div>
    <ping-thing-header />

    <div class="card mb-4">
      <div class="card-content">
        <div class="row px-xl-4">
          <div class="col-lg-2 px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-3 d-lg-none">5 min Stats&nbsp;</span>
            <span class="stat-title-4 text-success d-none d-lg-inline-block">5 min stats&nbsp;</span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4">
              <i class="fas fa-calculator text-success mr-2"></i>
              Entries:&nbsp;
            </span>
            <strong class="text-success">{{ count_last_5_minutes }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4">
              <i class="fas fa-long-arrow-alt-down text-success mr-1"></i>
              Min:&nbsp;
            </span>
            <strong class="text-success">{{ minimum_last_5_minutes? minimum_last_5_minutes.toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4">
              <i class="fas fa-divide text-success mr-1"></i>
              Median:&nbsp;
            </span>
            <strong class="text-success">{{ median_last_5_minutes ? median_last_5_minutes.toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 text-md-center">
            <span class="stat-title-4">
              <i class="fas fa-long-arrow-alt-up text-success mr-1" aria-hidden="true"></i>
              P90:&nbsp;
            </span>
            <strong class="text-success">{{ p90_last_5_minutes ? p90_last_5_minutes.toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
        </div>
      </div>
    </div>

    <div class="card mb-4">
      <div class="card-content">
        <h2 class="h3 card-heading">{{ network[0].toUpperCase() + network.substring(1) }} TX Confirmation Time Stats</h2>
        <stats-chart :network="network"/>
      </div>
    </div>

    <div class="card mb-4">
      <div class="card-content">
        <h2 class="h3 card-heading">TX Time Last Obervations</h2>
        <div class="text-center pb-4">
          <b-pagination
              v-model="page"
              :total-rows="total_count"
              :per-page="240"
              first-text="« First"
              last-text="Last »" />
        </div>
        <bubble-chart :vector="ping_things.slice().reverse()" />
      </div>
    </div>

    <div class="card">
      <ping-thing-table :ping_things="ping_things" />
      <b-pagination
          v-model="page"
          :total-rows="total_count"
          :per-page="240"
          first-text="« First"
          last-text="Last »" />
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import statsChart from './stats_chart'
  import bubbleChart from './bubble_chart'
  import pingThingHeader from './ping_thing_header'
  import pingThingTable from './ping_thing_table'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['network'],
    data () {
      var api_url = '/api/v1/ping-thing/' + this.network
      return {
        ping_things: [],
        page: 1,
        total_count: 0,
        api_url: api_url,
        p90_last_5_minutes: 0,
        count_last_5_minutes: 0,
        median_last_5_minutes: 0,
        minimum_last_5_minutes: 0
      }
    },
    created () {
      var ctx = this
      axios.get(ctx.api_url, { params: { with_stats: true } })
           .then(function(response){
             ctx.ping_things = response.data.ping_things;
             ctx.total_count = response.data.total_count;
             ctx.p90_last_5_minutes = response.data.p90_last_5_minutes;
             ctx.count_last_5_minutes = response.data.count_last_5_minutes;
             ctx.median_last_5_minutes = response.data.median_last_5_minutes;
             ctx.minimum_last_5_minutes = response.data.minimum_last_5_minutes
           })
    },
    watch: {
      page: function() {
        this.paginate()
      }
    },
    methods: {
      paginate: function(){
        var ctx = this
        axios.get(ctx.api_url, { params: { with_stats: true, page: ctx.page } })
             .then(function(response) {
               ctx.ping_things = response.data.ping_things
             })
      },
      reset_filters: function() {
        // TODO
      },
    },
    components: {
      "stats-chart": statsChart,
      "bubble-chart": bubbleChart,
      "ping-thing-header": pingThingHeader,
      "ping-thing-table": pingThingTable
    }
  }

</script>
