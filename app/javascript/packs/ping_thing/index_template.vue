<template>
  <div>
    <ping-thing-header />

    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading">{{ network[0].toUpperCase() + network.substring(1) }} TX Confirmation Time Stats</h3>
        <stats-chart :network="network"/>
      </div>
    </div>

    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading">TX Time Last Obervations</h3>
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
        api_url: api_url
      }
    },
    created () {
      var ctx = this
      axios.get(ctx.api_url, { params: { with_total_count: true } })
           .then(function(response){
             ctx.ping_things = response.data.ping_things;
             ctx.total_count = response.data.total_count;
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
        axios.get(ctx.api_url, { params: { with_total_count: true, page: ctx.page } })
             .then(response => (
               ctx.ping_things = response.data.ping_things
             ))
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
