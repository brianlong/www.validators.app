import axios from 'axios'
import Chart from 'chart.js/auto';
import chart_variables from '../validators/charts/chart_variables'
import { computed } from 'vue';

var moment = require('moment');

export default {
  props: {
    network: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      ping_thing_stats: null,
      chart: null,
      selected_region: null
    }
  },

  mounted: function() {
    
  },

  created: function() {
    this.load_chart_data()
  },

  methods: {
    load_chart_data: function() {
      var ctx = this
      axios.get("/api/v1/ping-thing-fee-stats/" + this.network + ".json", { params: { } })
           .then(function(response) {
             ctx.ping_thing_stats = response.data;
             ctx.selected_region = ctx.ping_regions()[0]
             console.log(ctx.ping_thing_stats)
             ctx.update_chart()
           })
    },

    ping_regions: function() {
      if (this.ping_thing_stats) {
        return Object.keys(this.ping_thing_stats)
      } else {
        return []
      }
    },

    select_region: function(region) {
      this.selected_region = region
      this.update_chart()
    },

    update_chart: function() {
      if( this.ping_thing_stats[this.selected_region] && this.selected_region) {
        var data_lines = []
        var line_colors = [chart_variables.chart_green_speedometer, chart_variables.chart_green, chart_variables.chart_blue, chart_variables.chart_purple_3, chart_variables.chart_purple_2, chart_variables.chart_purple_1]
        Object.keys(this.ping_thing_stats[this.selected_region]).map( (fee, index) => {
          data_lines.push(
            {
              type: 'line',
              data: this.ping_thing_stats[this.selected_region][fee].map( (vector_element) => ({y: vector_element['median_time'], x: moment(new Date(vector_element["created_at"])).utc().format('HH:mm')}) ),
              label: "P" + fee,
              backgroundColor: line_colors[index],
              borderColor: line_colors[index],
              borderWidth: 1,
            }
          )
        })

        // var labels = this.ping_thing_stats[this.selected_region][30].map( (vector_element) => {
        //   return moment(new Date(vector_element["created_at"])).utc().format('HH:mm')
        // })

        if(this.chart) {
          this.chart.destroy()
        }
        var ctx = document.getElementById("ping-thing-fee-chart").getContext('2d');
        Chart.defaults.scale.display = false
        this.chart = new Chart(ctx, {
          data: {
            // labels: labels,
            datasets: data_lines
          },
          options: {
            animations: {
              tension: {
                duration: 500,
                easing: 'easeInOutQuart',
              }
            },
            scales: {
              x: {
                display: true,
                grid: { display: false },
                ticks: {
                  display: true,
                  minRotation: 0,
                  maxRotation: 0,
                  autoSkip: true,
                  autoSkipPadding: 45
                },
                title: { display: false },
              },
              y: {
                display: true,
                min: 0,
                grid: { display: false },
                ticks: {
                  padding: 10,
                  callback: function(value) {
                    return value.toLocaleString('en-US')
                  }
                },
                title: {
                  display: true,
                  text: 'Response Time (ms)',
                  color: chart_variables.chart_darkgrey,
                  padding: 5
                }
              }
            },
            interaction: {
              intersect: false,
              mode: 'index',
            },
          }
        });
      }
    }
  },
  template: `
    <div>
      <div class="col-xl-12 mb-4">
        <div class="card h-100">
          <div class="card-content">
            <h2 class="h4 card-heading">
              Priority Fee Stats
            </h2>
            <div class="text-center mb-4">
              <div class="btn-group">
                <a v-for="region in ping_regions()" class="btn btn-sm btn-secondary nav-link" :class="{active: selected_region == region}" @click.prevent="select_region(region)">{{ region }}</a>
              </div>
            </div>
            <canvas :id="'ping-thing-fee-chart'"></canvas>
          </div>
        </div>
      </div>
      <div class="col-xl-12 mb-4">
        <div class="card">
          <div class="card-heading">
            <h2 class="h4 mt-4 card-heading">Last 1 Hour by Fee</h2>
          </div>
          <div class="table-responsive">
            <div class="h-100">
              <table class="table text-center">
                <thead>
                  <tr>
                    <th>Fee Percentile</th>
                    <th>Min Time (ms)</th>
                    <th>Median Time (ms)</th>
                    <th>P90 Time (ms)</th>
                    <th>Median Slot Latency</th>
                  </tr>
                </thead>
                <tbody>
                  <template v-for="region in ping_regions()">
                    <tr>
                      <th colspan="5"> {{ region }} </th>
                    </tr>
                    <tr v-for="fee in Object.keys(ping_thing_stats[region])">
                      <td>{{ fee }}</td>
                      <td class="text-success">{{ ping_thing_stats[region][fee][ping_thing_stats[region][fee].length - 1]['min_time'] }}</td>
                      <td class="text-success">{{ ping_thing_stats[region][fee][ping_thing_stats[region][fee].length - 1]['median_time'] }}</td>
                      <td class="text-success">{{ ping_thing_stats[region][fee][ping_thing_stats[region][fee].length - 1]['p90_time'] }}</td>
                      <td class="text-success">{{ ping_thing_stats[region][fee][ping_thing_stats[region][fee].length - 1]['median_slot_latency'] }}</td>
                    </tr>
                  </template>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
`
}
