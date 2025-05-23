import Chart from 'chart.js/auto'
import chart_variables from './chart_variables'

export default {
  props: {
    vote_latencies: {
        type: Array,
        required: true
    }
  },

  data() {
    return {
      default_score_class: "fas fa-circle me-1 score-",
      chart: null
    }
  },

  mounted() {
    this.update_chart()
  },

  watch: {
    'vote_blocks': {
      handler: function() {
        this.update_chart()
      }
    }
  },

  methods: {
    labels() {
      let labels = []
      this.vote_latencies.forEach(function(val) {
        labels.push(val['x'])
      })
      return labels
    },

    update_chart() {
      var ctx = document.getElementById("vote-latency-history").getContext('2d');

      if(this.chart) {
        this.chart.destroy()
      }

      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: this.labels(),
          datasets: [
            {
              label: ' Average Latency ',
              fill: true,
              borderColor: chart_variables.chart_purple_2,
              backgroundColor: chart_variables.chart_purple_2_t,
              borderWidth: 1,
              radius: 0,
              data: this.vote_latencies,
              tension: 0
            }
          ]
        },
        options: {
          scales: {
            x: {
              display: true,
              ticks: {
                display: true,
                minRotation: 0,
                maxRotation: 0,
                autoSkip: true,
                autoSkipPadding: 30
              },
              title: {
                display: true,
                text: "Previous " + this.vote_latencies.length + " Observations",
                color: chart_variables.chart_darkgrey
              }
            },
            y: {
              display: true,
              ticks: {
                min: 0,
                padding: 5
              },
              grid: {
                display: true,
                color: chart_variables.chart_grid_color
              },
              title: {
                display: true,
                text: "Slots",
                color: chart_variables.chart_darkgrey
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
                  return "Average Slots: " + tooltipItem.raw.y;
                },
                title: function(tooltipItem) {
                  return tooltipItem[0].label + " UTC";
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
          }
        },
        plugins: [{
          beforeInit(chart) {
            const originalFit = chart.legend.fit;
            chart.legend.fit = function fit() {
              originalFit.bind(chart.legend)();
              this.height += 12;
            }
          },
        }]
      });
    }
  },
  template: `
    <div class="col-lg-6">
      <div class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h4 card-heading mb-3">Vote Latency History</h2>
        </div>
        <div class="pb-3 px-3">
          <canvas id="vote-latency-history"></canvas>
        </div>
      </div>
    </div>
`
}
