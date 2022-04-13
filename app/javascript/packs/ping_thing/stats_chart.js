import axios from 'axios'
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../../lib/chart-financial';

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
  created: function(){
    this.load_chart_data()
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
        var ctx = this
        var line_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['median']) )
        var variation_data = this.ping_thing_stats.map( (vector_element, index) => ([vector_element['max'], vector_element['min']]) )
        var labels = this.ping_thing_stats.map( function(vector_element) {
            var hours = new Date(vector_element['time_from']).getHours()
            var minutes = new Date(vector_element['time_from']).getMinutes()
            if (minutes < 10) { minutes = "0"+minutes; }
            return hours + ":" + minutes
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
                        type: 'bar',
                        label: 'Variation',
                        data: variation_data,
                        backgroundColor: "rgba(221, 154, 229, 0.3)",
                        borderColor: "transparent",
                        order: 2,
                        barPercentage: 1.0,
                        categoryPercentage: 0.8
                    },
                    {
                        type: 'line',
                        label: 'Median',
                        data: line_data,
                        backgroundColor: "rgb(0, 206, 153)",
                        borderColor: "rgb(0, 206, 153)",
                        borderWidth: 1,
                        order: 1,
                        pointRadius: 3
                    }
                ]
            },
            options: {
                animation: { duration: 0 },
                hover: { mode: null },
                responsiveAnimationDuration: 0,
                legend: { display: false },
                scaleShowLabels : false,
                scaleFontSize: 0,
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
                            max: 60000,
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
                plugins: {
                    tooltip: {
                        displayColors: false,
                        padding: 8,
                        callbacks: {
                            label: function(tooltipItem) {
                                if (tooltipItem.datasetIndex == 0) {
                                    return "Min: " + tooltipItem.raw[1].toLocaleString('en-US') + " ms,  Max: " + tooltipItem.raw[0].toLocaleString('en-US') + " ms";
                                } else {
                                    return "Average: " + tooltipItem.formattedValue.toLocaleString('en-US') + " ms";
                                }
                            },
                            title: function(tooltipItem) {
                                return null;
                            },
                        }
                    }
                }
            }
        });
    }
  },
  template: `
    <div>
      <!--
      <div class="d-inline-block mb-4">
        <a class="btn btn-xs btn-secondary" href="#">Live</a>
      </div>
      -->
      <!--<div class="d-inline-block mb-4 float-md-right">-->
      <div class="text-center mb-4">
        <div class="btn-group">
          <a class="btn btn-xs btn-secondary nav-link" :class="{active: interval == 1}" @click.prevent="set_interval(1)">1h</a>
          <a class="btn btn-xs btn-secondary nav-link" :class="{active: interval == 3}" @click.prevent="set_interval(3)">3h</a>
          <a class="btn btn-xs btn-secondary nav-link" :class="{active: interval == 12}" @click.prevent="set_interval(12)">12h</a>
          <a class="btn btn-xs btn-secondary nav-link" :class="{active: interval == 24}" @click.prevent="set_interval(24)">24h</a>
        </div>
      </div>
      
      <canvas :id="'ping-thing-scatter-chart'"></canvas>
    </div>
`
}
