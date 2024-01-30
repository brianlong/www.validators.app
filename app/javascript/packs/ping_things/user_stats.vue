<template>
  <div class="row mb-4">
    <div class="col-12">
      <div class="card">
        <div class="table-responsive-lg">
          <table class="table text-center">
            <thead>
              <tr>
                <th>
                  User<br />
                  <span class="text-muted text-small">5 mins</span><br />
                  <span class="text-muted text-small">60 mins</span>
                </th>
                <th>
                  <i class="fa-solid fa-calculator text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  Entries
                </th>
                <th>
                  <i class="fa-solid fa-circle-xmark text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  Failures
                </th>
                <th>
                  <i class="fa-solid fa-down-long text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  Min
                </th>
                <th>
                  <i class="fa-solid fa-divide text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  Median
                </th>
                <th>
                  <i class="fa-solid fa-up-long text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  P90
                </th>
                <th>
                  <i class="fa-solid fa-clock text-success mx-3 mx-sm-3 ms-lg-0 me-lg-2"></i>
                  Latency
                </th>
              </tr>
            </thead>
            <tbody class="text-nowrap">
              <tr v-for="(stats_array, usr) in stats_grouped_by_user" :key="usr">
                <td>
                  {{ usr }}
                </td>
                <td class="text-success">
                  {{ stats_array["5min"]["num_of_records"] ? stats_array["5min"]["num_of_records"] : '0' }}
                  <br />
                  {{ stats_array["60min"]["num_of_records"] ? stats_array["60min"]["num_of_records"] : '0'}}
                </td>
                <td class="text-success">
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
                <td class="text-success">
                  {{ stats_array["5min"]["min"] ? stats_array["5min"]["min"] : 'N/A'}}
                  <br />
                  {{ stats_array["60min"]["min"] ? stats_array["60min"]["min"] : 'N/A'}}
                </td>
                <td class="text-success">
                  {{ stats_array["5min"]["median"] ? stats_array["5min"]["median"] : 'N/A'}}
                  <br />
                  {{ stats_array["60min"]["median"] ? stats_array["60min"]["median"] : 'N/A'}}
                </td>
                <td class="text-success">
                  {{ stats_array["5min"]["p90"] ? stats_array["5min"]["p90"] : 'N/A'}}
                  <br />
                  {{ stats_array["60min"]["p90"] ? stats_array["60min"]["p90"] : 'N/A'}}
                </td>
                <td class="text-success">
                  {{ stats_array["5min"]["average_slot_latency"] ? stats_array["5min"]["average_slot_latency"] : 'N/A'}}
                  <br />
                  {{ stats_array["60min"]["average_slot_latency"] ? stats_array["60min"]["average_slot_latency"] : 'N/A'}}
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
  import '../mixins/strings_mixins'
  import '../mixins/ping_things_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

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
      this.$cable.subscribe({
          channel: "PingThingUserStatChannel",
          room: "public",
        });
    },

    computed: {
      stats_grouped_by_user: function() {
        let grouped = {}
        let usernames = Object.keys(this.last_5_mins).concat(Object.keys(this.last_60_mins))
        usernames = [...new Set(usernames)]
        let ctx = this
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
