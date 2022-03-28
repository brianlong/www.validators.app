<template>
  <div>
    <ping-thing-header />

    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading mb-4">{{ network[0].toUpperCase() + network.substring(1) }} TX Confirmation Time</h3>
        <scatter-chart :vector="ping_things.slice().reverse()" fill_color="rgba(221, 154, 229, 0.4)" line_color="rgb(221, 154, 229)"/>
      </div>
    </div>

    <div class="card">
      <ping-thing-table :ping_things="ping_things" :page="page" :total_count="total_count" />
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import scatterChart from './scatter_chart'
  import pingThingHeader from './ping_thing_header'
  import pingThingTable from './ping_thing_table'
  import Ping_thing_table from './ping_thing_table.vue'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['network'],
    data () {
      var api_url = '/api/v1/ping-thing/' + this.network + '?'
      return {
        ping_things: [],
        page: 1,
        total_count: 0,
        api_url: api_url
      }
    },
    created () {
      var ctx = this
      var url = ctx.api_url + 'with_total_count=true'

      axios.get(url)
           .then(function(response){
             ctx.ping_things = response.data.ping_things;
             ctx.total_count = response.data.total_count;
           })
    },
    watch: {
      page: function(){
        this.paginate()
      }
    },
    components: {
      "scatter-chart": scatterChart,
      "ping-thing-header": pingThingHeader,
      "ping-thing-table": pingThingTable
    }
  }

</script>
