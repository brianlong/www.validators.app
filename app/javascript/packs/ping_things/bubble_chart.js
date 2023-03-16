import Chart from 'chart.js/auto'
import chart_variables from '../validators/charts/chart_variables'

export default {
  props: {
    vector: {
      type: Array,
      required: true
    },
    network: {
        type: String,
        required: true
    }
  },

  data() {
    return {
      chart: null
    }
  },

  watch: {
    'vector': {
      handler: function() {
        this.update_chart()
      }
    }
  },

  methods: {
    update_chart: function() {
      if(this.chart) {
        this.chart.destroy()
      }
      var ctx = document.getElementById("ping-thing-bubble-chart").getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'bubble',
        data: {
          datasets: [
            {
              data: this.vector.map( (vector_element, index) => ({ x: index, y: vector_element['response_time'], z: 1 }) ),
              borderColor: chart_variables.chart_purple_2,
              backgroundColor: chart_variables.chart_purple_2_t,
              borderWidth: 1,
              radius: 3,
              tension: 0
            }
          ],
        },

        options: {
          scales: {
            x: {
              display: true,
              ticks: { display: false },
              grid: { display: false },
              title: {
                display: true,
                text: "Last " + this.vector.length + " Observations",
                color: chart_variables.chart_darkgrey
              }
            },
            y: {
              display: true,
              min: 0,
              ticks: {
                padding: 10,
                callback: function(value, index, values) {
                  return value.toLocaleString('en-US')
                }
              },
              grid: {
                display: true,
                color: chart_variables.chart_grid_color
              },
              title: {
                display: true,
                text: 'Response Time (ms)',
                color: chart_variables.chart_darkgrey,
                padding: 5
              }
            }
          },
          animation: { duration: 0 },
          plugins: {
            tooltip: {
              enabled: true,
              displayColors: false,
              padding: 8,
              callbacks: {
                label: function(tooltipItem) {
                  return tooltipItem.raw.y.toLocaleString('en-US').concat(' ms');
                },
              },
            },
            legend: { display: false },
          },
        },
      });
    }
  },
  template: `
    <canvas :id="'ping-thing-bubble-chart'"></canvas>
`
}
