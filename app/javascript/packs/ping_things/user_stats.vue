<template>
  <div class="row mb-4">
    <div class="col-12">
      <div class="card">
        <div class="table-responsive-lg">
          <table class="table text-center">
            <thead>
              <tr>
                <th class="column-sm px-0">
                  User<br />
                  <small class="text-muted text-small">5 min / 60 min</small>
                </th>
                <th class="column-xs px-0">
                  <i class="fa-solid fa-calculator text-success me-2"></i>Entries
                </th>
                <th class="column-sm px-0">
                  <i class="fa-solid fa-circle-xmark text-success me-2"></i>Errors
                </th>
                <th class="column-xl px-0" colspan="3">
                  <i class="fa-solid fa-clock text-success me-2"></i>Time (ms)<br />
                  <small class="text-muted text-small">min / median / p90</small>
                </th>
                <th class="column-lg px-0" colspan="3">
                  <i class="fa-solid fa-stopwatch text-success me-2"></i>Slot Latency<br />
                  <small class="text-muted text-small">min / median / p90</small>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(stats_array, usr) in stats_grouped_by_user" :key="usr">
                <td>
                  {{ usr }}
                </td>
                <td class="text-success">
                  {{ stats_array["5min"]["num_of_records"] ? stats_array["5min"]["num_of_records"] : '0' }}
                  <br />
                  {{ stats_array["60min"]["num_of_records"] ? stats_array["60min"]["num_of_records"] : '0'}}
                </td>
                <td class="text-success text-nowrap">
                  {{ stats_array["5min"]["fails_count"] ? stats_array["5min"]["fails_count"] : '0'}}
                  <span class="text-muted text-small">
                    {{ fails_count_percentage(stats_array["5min"]["fails_count"], stats_array["5min"]["num_of_records"]) }}
                  </span>
                  <br />
                  {{ stats_array["60min"]["fails_count"] ? stats_array["60min"]["fails_count"] : '0'}}
                  <span class="text-muted">
                    {{ fails_count_percentage(stats_array["60min"]["fails_count"], stats_array["60min"]["num_of_records"]) }}
                  </span>
                </td>
                <td class="text-success-darker text-nowrap ps-5">
                  {{ attribute_valid(stats_array["5min"]["min"]) ? stats_array["5min"]["min"].toLocaleString('en-US') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["min"]) ? stats_array["60min"]["min"].toLocaleString('en-US') : 'N/A' }}
                </td>
                <td class="text-success text-nowrap px-0">
                  {{ attribute_valid(stats_array["5min"]["median"]) ? stats_array["5min"]["median"].toLocaleString('en-US') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["median"]) ? stats_array["60min"]["median"].toLocaleString('en-US') : 'N/A' }}
                </td>
                <td class="text-success-darker text-nowrap pe-5">
                  {{ attribute_valid(stats_array["5min"]["p90"]) ? stats_array["5min"]["p90"].toLocaleString('en-US') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["p90"]) ? stats_array["60min"]["p90"].toLocaleString('en-US') : 'N/A' }}
                </td>

                <td class="text-success-darker text-nowrap ps-4 ps-lg-5">
                  {{ attribute_valid(stats_array["5min"]["min_slot_latency"]) ? stats_array["5min"]["min_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["5min"]["min_slot_latency"], 'slot') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["min_slot_latency"]) ? stats_array["60min"]["min_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["60min"]["min_slot_latency"], 'slot') : 'N/A' }}
                </td>
                <td class="text-success text-nowrap ps-0 ps-xl-1 pe-0">
                  {{ attribute_valid(stats_array["5min"]["average_slot_latency"]) ? stats_array["5min"]["average_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["5min"]["average_slot_latency"] , 'slot') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["average_slot_latency"]) ? stats_array["60min"]["average_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["60min"]["average_slot_latency"] , 'slot') : 'N/A' }}
                </td>
                <td class="text-success-darker text-nowrap pe-4 pe-lg-5">
                  {{ attribute_valid(stats_array["5min"]["p90_slot_latency"]) ? stats_array["5min"]["p90_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["5min"]["p90_slot_latency"], 'slot') : 'N/A' }}
                  <br />
                  {{ attribute_valid(stats_array["60min"]["p90_slot_latency"]) ? stats_array["60min"]["p90_slot_latency"].toLocaleString('en-US') + pluralize(stats_array["60min"]["p90_slot_latency"], 'slot') : 'N/A' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    props: {
      network: {
        default: "mainnet"
      }
    },

    data () {
      return {
        last_5_mins: {},
        last_60_mins: {},
        api_url: null
      }
    },

    created () {
      this.api_url = '/api/v1/ping-thing-user-stats/' + this.network
      var ctx = this
      axios.get(ctx.api_url)
           .then(function(response) {
             ctx.last_5_mins = JSON.parse(response.data.last_5_mins) ? JSON.parse(response.data.last_5_mins) : {};
             ctx.last_60_mins = JSON.parse(response.data.last_60_mins) ? JSON.parse(response.data.last_60_mins) : {};
           })
    },

    mounted: function() {
      // this.$cable.subscribe({
      //     channel: "PingThingUserStatChannel",
      //     room: "public",
      //   });
    },

    computed: {
      stats_grouped_by_user: function() {
        let ctx = this

        // set order: from highest 60min num_of_records to lowest
        let keys = Object.keys(ctx.last_60_mins);
        let usernames = keys.sort(function(a, b) {
          return ctx.last_60_mins[b][0]["num_of_records"] - ctx.last_60_mins[a][0]["num_of_records"]
        })

        // group last_60_mins and last_5_mins hashes by username
        let grouped = {}
        usernames.forEach(function(name) {
          grouped[name] = {
            "5min": {},
            "60min": {}
          }
          if(ctx.last_5_mins[name]) {
            grouped[name]["5min"] = ctx.last_5_mins[name].constructor === Array ? ctx.last_5_mins[name][0] : ctx.last_5_mins[name]
          }
          if(ctx.last_60_mins[name]) {
            grouped[name]["60min"] = ctx.last_60_mins[name].constructor === Array ? ctx.last_60_mins[name][0] : ctx.last_60_mins[name]
          }
        })
        return grouped
      }
    },

    methods: {
      attribute_valid: function(attr) {
        return (typeof attr !== 'undefined' && attr !== null)
      },
    },

    channels: {
      PingThingUserStatChannel: {
        connected() {},
        rejected() {},
        received(data) {
          data = JSON.parse(data)
          if(data["network"] == this.network) {
              switch(data["interval"]) {
                case 5:
                  this.last_5_mins = data["stats"]
                  break
                case 60:
                  this.last_60_mins = data["stats"]
                  break
              }
          }
        },
        disconnected() {},
      },
    },
  }
</script>
