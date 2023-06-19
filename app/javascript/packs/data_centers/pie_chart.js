import Chart from 'chart.js/auto'
import chart_variables from '../validators/charts/chart_variables'

export default {
  props: {
    data_center_stats: {
        type: Array,
        required: true
    },
    chart_title: {
        type: String,
        required: true
    }
  },

  data() {
    return {
      chart: null
    }
  },

  mounted() {
    this.update_chart()
  },

  computed: {
    data_center_stats_for_chart() {
      let arr = this.data_center_stats.slice(0, 5);
      let other_sum = 0;
      for (const [key, value] of Object.entries(this.data_center_stats.slice(6, -1))) {
        other_sum += value[1]
      }
      arr.push(['Other', other_sum])
      return arr
    }
  },

  methods: {
    labels() {
      let labels = []
      this.data_center_stats_for_chart.forEach(function(val) {
        labels.push(val[0] + ' (' + val[1] + ')')
      })
      return labels
    },

    chart_name() {
      return this.chart_title.replace(/ /g,"-").toLowerCase() + '-chart'
    },

    update_chart() {
      var ctx = document.getElementById(this.chart_name()).getContext('2d');

      if(this.chart) {
        this.chart.destroy()
      }

      this.chart = new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: this.labels(),
          datasets: [
            {
              label: ' Block Diff ',
              data: this.data_center_stats_for_chart.map( (k) => ( k[1] ) ),
              backgroundColor: [
                chart_variables.chart_green_speedometer,
                chart_variables.chart_green_t,
                chart_variables.chart_blue_speedometer,
                chart_variables.chart_blue_t,
                chart_variables.chart_purple_2_m,
                chart_variables.chart_lightgrey_speedometer,
              ],
              borderColor: chart_variables.chart_grid_color,
              borderWidth: 1,
            }
          ]
        },
        options: {
          plugins: {
            legend: {
              position: 'bottom',
              minHeight: 100,
              align: 'start',
              labels: {
                usePointStyle: true,
                color: chart_variables.chart_lightgrey,
                padding: 20,
              }
            }
          }
        }
      });
    }
  },
  template: `
    <canvas :id="chart_name()"></canvas>
`
}
