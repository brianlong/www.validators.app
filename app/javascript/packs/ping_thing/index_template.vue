<template>
  <div>
    <ping-thing-header />

    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading mb-4">{{ network[0].toUpperCase() + network.substring(1) }} TX Confirmation Time</h3>
        <scatter-chart :vector="ping_things" fill_color="rgba(221, 154, 229, 0.4)" line_color="rgb(221, 154, 229)"/>
      </div>
    </div>

    <div class="card">
      <ping-thing-table :ping_things="ping_things"/>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import loadingImage from 'loading.gif'
  import scatterChart from './scatter_chart'
  import pingThingHeader from './ping_thing_header'
  import pingThingTable from './ping_thing_table'
  import Ping_thing_table from './ping_thing_table.vue'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['network'],
    data () {
      return {
        ping_things: []
      }
    },
    created () {
      var ctx = this
      axios.get("/api/v1/ping-thing/" + this.network)
           .then(function(response){
             ctx.ping_things = response.data
           })
    },
    components: {
      "scatter-chart": scatterChart,
      "ping-thing-header": pingThingHeader,
      "ping-thing-table": pingThingTable,
        Ping_thing_table
    }
  }

</script>
