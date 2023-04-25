<template>
  <div>
    <ping-thing-header />

    <stats-bar :network="network"/>

    <div class="card mb-4">
      <div class="card-content">
        <h2 class="h4 card-heading">
          {{ capitalize(network) }} TX Confirmation Time Stats
        </h2>
        <stats-chart :network="network"/>
      </div>
    </div>

    <div class="card mb-4">
      <div class="card-content">
        <h2 class="h4 card-heading">TX Time Last Obervations</h2>
        <bubble-chart :vector="ping_things.slice().reverse()" :network="network"/>
      </div>
    </div>

    <ping-thing-table :ping_things="ping_things_for_table()" :network="network" />
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import statsChart from './stats_chart'
  import bubbleChart from './bubble_chart'
  import pingThingHeader from './ping_thing_header'
  import pingThingTable from './ping_thing_table'
  import statsBar from './stats_bar'
  import '../mixins/strings_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    data () {
      return {
        ping_things: [],
        page: 1,
        records_in_table: 120,
        api_url: null
      }
    },

    created () {
      this.api_url = '/api/v1/ping-thing/' + this.network
      var ctx = this
      axios.get(ctx.api_url)
           .then(function(response) {
             ctx.ping_things = response.data;
           })
    },

    channels: {
      PingThingChannel: {
        connected() {},
        rejected() {},
        received(data) {
          if(data["network"] == this.network) {
              this.ping_things.unshift(data)
              this.ping_things.pop()
          }
        },
        disconnected() {},
      },
    },

    mounted: function() {
      this.$cable.subscribe({
          channel: "PingThingChannel",
          room: "public",
        });
    },

    computed: mapGetters([
      'network'
    ]),

    methods: {
      ping_things_for_table: function() {
        if(this.ping_things.length <= this.records_in_table) {
          return this.ping_things
        } else {
          return this.ping_things.slice(0, this.records_in_table)
        }
      }
    },

    components: {
      "stats-chart": statsChart,
      "bubble-chart": bubbleChart,
      "ping-thing-header": pingThingHeader,
      "ping-thing-table": pingThingTable,
      "stats-bar": statsBar
    }
  }

</script>
