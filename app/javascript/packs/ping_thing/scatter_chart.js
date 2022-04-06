import axios from 'axios'
import Chart from 'chart.js/auto';
import { DateTime } from "luxon";
import 'chartjs-adapter-luxon';
import '../../lib/chart-financial';

export default {
  props: {
    fill_color: {
      type: String,
      required: true
    },
    line_color: {
      type: String,
      required: true
    },
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
      chart: null
    }
  },
  created: function(){
    var ctx = this
    axios.get("/api/v1/ping-thing-stats/" + this.network, { params: { interval: 6 } })
        .then(function(response){
            ctx.ping_thing_stats = response.data;
            ctx.update_chart()
        })
  },
  watch: {
      'ping_thing_stats': {
        handler: function(){
            this.update_chart()
        }
      }
  },
  methods: {
    update_chart: function(){
        var line_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['median']) )
        var max_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['max']) )
        var min_data = this.ping_thing_stats.map( (vector_element, index) => (vector_element['min']) )
        var labels = this.ping_thing_stats.map( (vector_element, index) => (
            new Date(vector_element['time_from']).getHours().toString() + ":" + new Date(vector_element['time_from']).getMinutes().toString()
        ))

        if(this.chart){
            this.chart.destroy()
        }
        var ctx = document.getElementById("ping-thing-scatter-chart").getContext('2d');
        this.chart = new Chart(ctx, {
            data: {
                labels: labels,
                datasets: [
                    {
                        type: 'line',
                        label: 'Median',
                        data: line_data,
                        backgroundColor: null,
                        borderColor: '#00CE98',
                        order: 1,
                        xAxisID: "line-1"
                    },
                    {
                        type: 'bar',
                        label: '',
                        data: min_data,
                        backgroundColor: "#161228", 
                        borderColor: this.line_color,
                        order: 1,
                        xAxisID: "bar-1"
                    },
                    {
                        type: 'bar',
                        label: 'Variation',
                        data: max_data,
                        backgroundColor: "#AA2EB8",
                        borderColor: this.line_color,
                        order: 1,
                        xAxisID: "bar-2"
                    }
                ]
            },
            options: {
                animation: { duration: 0 },
                elements: { line: { tension: 0 } },
                hover: { mode: null },
                tooltips: { enabled: false },
                responsiveAnimationDuration: 0,
                legend: { display: false },
                scales: {
                    xAxes: [{
                        display: false,
                        ticks: { display: false },
                        gridLines: { display: false },
                        scaleLabel: {
                            display: false,
                            labelString: ''
                        }
                    },{
                        display: false,
                        ticks: { display: false },
                        gridLines: { display: false },
                        scaleLabel: {
                            display: false,
                            labelString: ''
                        }
                    },{
                        display: false,
                        ticks: { display: false },
                        gridLines: { display: false },
                        scaleLabel: {
                            display: false,
                            labelString: ''
                        }
                    }],
                    y: {
                        display: true,
                        gridLines: { display: false },
                    }
                }
            }
        });
    }
  },
  template: `
    <canvas :id="'ping-thing-scatter-chart'"></canvas>
`
}
