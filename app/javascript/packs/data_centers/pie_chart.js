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
    },
    chart_by: {
        type: String,
        required: false,
        default: 'stake'
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
      let ctx = this
      this.data_center_stats_for_chart.forEach(function(val) {
        let label_value = val[1]
        if(ctx.chart_by == 'stake') {
          label_value = ctx.lamports_to_sol(val[1]).toFixed(2) + " SOL"
        }
        labels.push(val[0] + ' (' + label_value + ') ')
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
              data: this.data_center_stats_for_chart.map( (k) => ( k[1] ) ),
              backgroundColor: [
                chart_variables.chart_green_speedometer,
                chart_variables.chart_green_t,
                chart_variables.chart_blue_speedometer,
                chart_variables.chart_blue_t,
                chart_variables.chart_purple_2_m,
                chart_variables.chart_lightgrey_speedometer,
              ],
              borderColor: [
                chart_variables.chart_green_speedometer,
                chart_variables.chart_green_t,
                chart_variables.chart_blue_speedometer,
                chart_variables.chart_blue_t,
                chart_variables.chart_purple_2_m,
                chart_variables.chart_lightgrey_speedometer,
              ],
              borderWidth: 1,
            }
          ]
        },
        options: {
          plugins: {
            tooltip: {
              enabled: true,
              displayColors: false,
              padding: 8,
              callbacks: {
                label: function(tooltipItem) {
                  return tooltipItem.label;
                },
              }
            },
            legend: {
              minHeight: 100,
              labels: {
                boxWidth: chart_variables.chart_legend_box_size,
                boxHeight: chart_variables.chart_legend_box_size,
                usePointStyle: true,
                color: chart_variables.chart_lightgrey,
                padding: 10,
                font: {
                  size: chart_variables.chart_legend_font_size
                }
              }
            }
          }
        },
        plugins: [{
          beforeInit(chart) {
            const originalFit = chart.legend.fit;
            chart.legend.fit = function fit() {
              originalFit.bind(chart.legend)();
              this.height += 20;
            }
          }
        }]
      });
    }
  },
  template: `
    <canvas :id="chart_name()"></canvas>
  `
}
