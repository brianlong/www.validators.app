<template>
  <div>
    <ping-thing-header />

    <stats-bar :network="network"/>

    <div class="row">
      <div class="col-xl-6 mb-4">
        <div class="card h-100">
          <div class="card-content">
            <h2 class="h4 card-heading">
              TX Confirmation Time Stats
            </h2>
            <stats-chart :network="network"/>
          </div>
        </div>
      </div>

      <div class="col-xl-6 mb-4">
        <div class="card h-100">
          <div class="card-content">
            <h2 class="h4 card-heading">
              TX Time Last Obervations
            </h2>
            <bubble-chart :vector="ping_things.slice().reverse()" :network="network"/>
          </div>
        </div>
      </div>

      <fee-stats-chart :network="network"/>
    </div>
    <user-stats :network="network"/>

    <ping-thing-table :network="network" />
  </div>
</template>

<script>
  import axios from 'axios'
  import { mapGetters } from 'vuex'
  import statsChart from './stats_chart'
  import feeStatsChart from './fee_stats_chart'
  import bubbleChart from './bubble_chart'
  import pingThingHeader from './ping_thing_header'
  import pingThingTable from './ping_thing_table'
  import statsBar from './stats_bar'
  import userStats from './user_stats'
  import '../mixins/strings_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    data () {
      return {
        ping_things: [],
        page: 1,
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

    computed: {
      ping_things_grouped_by_user: function() {
        return this.ping_things.reduce(function(acc, obj) {
          var key = obj.username;
          if(!acc[key]) {
            acc[key] = {}
            acc[key]["5min"] = [];
            acc[key]["60min"] = [];
          }
          if (Moment(obj.reported_at).isAfter(Moment().subtract(5, 'minutes'))) {
            acc[key]["5min"].push(obj);
          } else if (Moment(obj.reported_at).isAfter(Moment().subtract(60, 'minutes'))) {
            acc[key]["60min"].push(obj);
          }
          return acc;
        }, {});
      },
      ...mapGetters([
        'network'
      ])
    }
,

    methods: {},

    components: {
      "stats-chart": statsChart,
      "bubble-chart": bubbleChart,
      "ping-thing-header": pingThingHeader,
      "ping-thing-table": pingThingTable,
      "stats-bar": statsBar,
      "user-stats": userStats,
      "fee-stats-chart": feeStatsChart
    }
  }

</script>
