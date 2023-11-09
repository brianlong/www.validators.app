import axios from 'axios'
import Chart from 'chart.js/auto';
import chart_variables from '../validators/charts/chart_variables'

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
      interval: 1
    }
  },

  channels: {
    PingThingStatChannel: {
      connected() {},
      rejected() {},
      received(data) {
        var new_stat = JSON.parse(data)
        if(new_stat["interval"] == this.interval && new_stat["network"] == this.network) {
          this.ping_thing_stats.push(new_stat)
          this.ping_thing_stats.shift()
          this.update_chart()
        }
      },
      disconnected() {},
    },
  },

  created: function() {
    this.load_chart_data()
  },

  mounted: function() {
    this.$cable.subscribe({
      channel: "PingThingStatChannel",
      room: "public",
    });
  },

  methods: {
    set_interval: function(interval) {
      this.interval = interval
      this.load_chart_data()
    },

    load_chart_data: function() {
      var ctx = this
      axios.get("/api/v1/ping-thing-stats/" + this.network, { params: { interval: this.interval } })
           .then(function(response) {
             ctx.ping_thing_stats = response.data;
             ctx.update_chart()
           })
    },

    update_chart: function() {
      if( !this.ping_thing_stats.length == 0 ) {
        var line_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['median']) )
        var variation_data = this.ping_thing_stats.map( (vector_element, index) => (
          [vector_element['max'], vector_element['min'], vector_element['average_slot_latency']]
        ))
        var tps_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['tps']) )

        var labels = this.ping_thing_stats.map( (vector_element) => {
          if(this.interval > 24) {
            return moment(new Date(vector_element["time_from"])).utc().format('HH:mm (ddd)')
          } else {
            return moment(new Date(vector_element["time_from"])).utc().format('HH:mm')
          }
        })

        if(this.chart) {
          this.chart.destroy()
        }
        var ctx = document.getElementById("ping-thing-scatter-chart").getContext('2d');
        Chart.defaults.scale.display = false
        this.chart = new Chart(ctx, {
          data: {
            labels: labels,
            datasets: [
              {
                type: 'bar',
                label: ' Variation',
                data: variation_data,
                backgroundColor: chart_variables.chart_purple_2_t,
                hoverBackgroundColor: chart_variables.chart_purple_2_m,
                borderColor: "transparent",
                order: 2,
                barPercentage: 1.0,
                categoryPercentage: 0.15,
                tension: 0
              },
              {
                type: 'line',
                label: ' Median  ',
                data: line_data,
                backgroundColor: chart_variables.chart_green,
                borderColor: "transparent",
                borderWidth: 1,
                order: 1,
                radius: 3,
                tension: 0
              },
              {
                type: 'line',
                label: ' TPS  ',
                data: tps_data,
                backgroundColor: chart_variables.chart_blue,
                yAxisID: 'yTPS',
                borderColor: chart_variables.chart_blue_t,
                // borderWidth: 1,
                // order: 1,
                // radius: 3,
                // tension: 0
              }
            ]
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
              },
              yTPS: {
                display: true,
                min: 0,
                grid: { display: false },
                position: 'right',
                ticks: {
                  padding: 10,
                  callback: function(value) {
                    return value.toLocaleString('en-US')
                  }
                },
                title: {
                  display: true,
                  text: 'Number of Transactions',
                  color: chart_variables.chart_darkgrey,
                  padding: 5
                }
              }
            },
            interaction: {
              intersect: false,
              mode: 'index',
            },
            plugins: {
              tooltip: {
                enabled: true,
                displayColors: false,
                padding: 8,
                callbacks: {
                  label: function(tooltipItem) {
                    if (tooltipItem.datasetIndex == 0) {
                      var min = tooltipItem.raw[1] ? tooltipItem.raw[1].toLocaleString('en-US') : "-";
                      var max = tooltipItem.raw[0] ? tooltipItem.raw[0].toLocaleString('en-US') : "-";
                      var slot_lat = tooltipItem.raw[2] ? tooltipItem.raw[2].toLocaleString('en-US') : "-";
                      return ["Min: " + min + " ms, Max: " + max + " ms", "Average slot latency: " + slot_lat + " slots"];
                    } else if (tooltipItem.datasetIndex == 2) {
                      return "TPS: " + tooltipItem.raw.toLocaleString('en-US');
                    } else {
                      return "Median: " + tooltipItem.raw.toLocaleString('en-US') + " ms";
                    }
                  },
                  title: function(tooltipItem) {
                    return null;
                  },
                }
              },
              legend: {
                labels: {
                  boxWidth: chart_variables.chart_legend_box_size,
                  boxHeight: chart_variables.chart_legend_box_size,
                  usePointStyle: true,
                  padding: 10,
                  color: chart_variables.chart_darkgrey,
                  font: {
                    size: chart_variables.chart_legend_font_size
                  }
                },
              },
            },
          },
          plugins: [{
            beforeInit(chart) {
              const originalFit = chart.legend.fit;
              chart.legend.fit = function fit() {
                originalFit.bind(chart.legend)();
                this.height += 15;
              }
            }
          }]
        });
      }
    }
  },
  template: `
    <div>
      <div class="text-center mb-4">
        <div class="btn-group">
          <a class="btn btn-sm btn-secondary nav-link" :class="{active: interval == 1}" @click.prevent="set_interval(1)">1h</a>
          <a class="btn btn-sm btn-secondary nav-link" :class="{active: interval == 3}" @click.prevent="set_interval(3)">3h</a>
          <a class="btn btn-sm btn-secondary nav-link" :class="{active: interval == 12}" @click.prevent="set_interval(12)">12h</a>
          <a class="btn btn-sm btn-secondary nav-link" :class="{active: interval == 24}" @click.prevent="set_interval(24)">24h</a>
          <a class="btn btn-sm btn-secondary nav-link" :class="{active: interval == 168}" @click.prevent="set_interval(168)">7d</a>
        </div>
      </div>
      
      <canvas :id="'ping-thing-scatter-chart'"></canvas>
    </div>
`
}
