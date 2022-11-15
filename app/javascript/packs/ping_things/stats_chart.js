import axios from 'axios'
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../../lib/chart-financial';

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
      dark_grey: "#979797",
      chart_line: "#322f3d",
      chart: null,
      interval: 1
    }
  },
  channels: {
    PingThingStatChannel: {
      connected() {
        //   console.log("connected to PingThingStats")
      },
      rejected() {},
      received(data) {
        var new_stat = JSON.parse(data)
        if(new_stat["interval"] == this.interval && new_stat["network"] == this.network){
            this.ping_thing_stats.push(new_stat)
            this.ping_thing_stats.shift()
            this.update_chart()
        }
      },
      disconnected() {},
    },
  },
  created: function(){
    this.load_chart_data()
  },
  mounted: function(){
    this.$cable.subscribe({
        channel: "PingThingStatChannel",
        room: "public",
      });
  },
  methods: {
    set_interval: function(interval){
        this.interval = interval
        this.load_chart_data()
    },
    load_chart_data: function(){
        var ctx = this
        axios.get("/api/v1/ping-thing-stats/" + this.network, { params: { interval: this.interval } })
            .then(function(response){
                ctx.ping_thing_stats = response.data;
                ctx.update_chart()
            })
    },
    update_chart: function(){
        if( !this.ping_thing_stats.length == 0 ){
            var line_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['median']) )
            var variation_data = this.ping_thing_stats.map( (vector_element, index) => (
                [vector_element['max'], vector_element['min'], vector_element['average_slot_latency']]
            ))
            var labels = this.ping_thing_stats.map( (vector_element) => {
                if(this.interval > 24){
                    return moment(new Date(vector_element["time_from"])).utc().format('HH:mm (ddd)')
                } else {
                    return moment(new Date(vector_element["time_from"])).utc().format('HH:mm')
                }
            })

            if(this.chart){
                this.chart.destroy()
            }
            var ctx = document.getElementById("ping-thing-scatter-chart").getContext('2d');
            Chart.defaults.scale.display = false
            this.chart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: ' Variation',
                            data: variation_data,
                            backgroundColor: "rgba(221, 154, 229, 0.4)",
                            hoverBackgroundColor: "rgba(221, 154, 229, 0.7)",
                            borderColor: "transparent",
                            order: 2,
                            barPercentage: 1.0,
                            categoryPercentage: 0.15
                        },
                        {
                            type: 'line',
                            label: ' Median  ',
                            data: line_data,
                            backgroundColor: "rgb(0, 206, 153)",
                            borderColor: "transparent",
                            borderWidth: 1,
                            order: 1,
                            pointRadius: 3
                        }
                    ]
                },
                options: {
                    animation: {
                        duration: 500,
                        easing: 'easeInOutQuart'
                    },
                    scales: {
                        x: {
                            display: true,
                            gridLines: { display: false },
                            ticks: {
                                minRotation: 0,
                                maxRotation: 0,
                                autoSkip: true,
                                autoSkipPadding: 45
                            }
                        },
                        y: {
                            display: true,
                            gridLines: { display: false },
                            ticks: {
                                min: 0,
                                padding: 10,
                                callback: function(value, index, values) {
                                    return value.toLocaleString('en-US')
                                }
                            },
                            title: {
                                display: true,
                                text: 'Response Time (ms)',
                                color: this.dark_grey,
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
                            displayColors: false,
                            padding: 8,
                            callbacks: {
                                label: function(tooltipItem) {
                                    if (tooltipItem.datasetIndex == 0) {
                                        var min = tooltipItem.raw[1] ? tooltipItem.raw[1].toLocaleString('en-US') : "-";
                                        var max = tooltipItem.raw[0] ? tooltipItem.raw[0].toLocaleString('en-US') : "-";
                                        var slot_lat = tooltipItem.raw[2] ? tooltipItem.raw[2].toLocaleString('en-US') : "-";

                                        return ["Min: " + min + " ms, Max: " + max + " ms", "Average slot latency: " + slot_lat + " slots"];
                                    } else {
                                        return "Median: " + tooltipItem.formattedValue.toLocaleString('en-US') + " ms";
                                    }
                                },
                                title: function(tooltipItem) {
                                    return null;
                                },
                            }
                        },
                        legend: {
                            labels: {
                                boxWidth: 8,
                                boxHeight: 8,
                                usePointStyle: true,
                                padding: 10,
                                color: this.dark_grey,
                                font: {
                                    size: 14
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
