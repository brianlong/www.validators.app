import Chart from 'chart.js/auto'
import chart_variables from './chart_variables'

export default {
  props: {
    skipped_after: {
      type: Object,
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
    'skipped_slots': {
      handler: function() {
        this.update_chart()
      }
    }
  },

  computed: {
    skipped_after_array() {
      let arr = []
      for (const [key, value] of Object.entries(this.skipped_after)) {
        arr.push(value)
      }
      return arr
    }
  },

  methods: {
    labels() {
      let labels = []
      this.skipped_after_array.forEach(function(val) {
        labels.push(val['label'])
      })
      return labels
    },

    update_chart() {
      var ctx = document.getElementById("skipped-after-history").getContext('2d');

      if(this.chart) {
        this.chart.destroy()
      }
      
      var skipped_after_percent_moving_average = this.skipped_after_array.map( (vector_element, index) => (
        vector_element['skipped_after_percent_moving_average']
      ))
      var skipped_after_percent = this.skipped_after_array.map( (vector_element, index) => (
        vector_element['skipped_after_percent']
      ))

      var cluster_skipped_after_percent_moving_average = this.skipped_after_array.map( (vector_element, index) => (
        vector_element['cluster_skipped_after_percent_moving_average']
      ))

      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: this.labels(),
          datasets: [
            {
              label: ' Moving Avg  ',
              fill: false,
              borderColor: chart_variables.chart_purple_1,
              backgroundColor: chart_variables.chart_purple_1_t,
              borderWidth: 1,
              radius: 0,
              data: skipped_after_percent_moving_average
            },
            {
              label: ' Actual Skipped After Slots  ',
              fill: false,
              borderColor: chart_variables.chart_purple_2,
              backgroundColor: chart_variables.chart_purple_2_t,
              borderWidth: 1,
              borderDash: [2, 2],
              radius: 0,
              data: skipped_after_percent
            },
            {
              label: ' Cluster Avg',
              fill: false,
              borderColor: chart_variables.chart_purple_3,
              backgroundColor: chart_variables.chart_purple_3_t,
              borderWidth: 1,
              radius: 0,
              data: cluster_skipped_after_percent_moving_average
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
              grid: { display: false },
              title: {
                display: true,
                text: "Previous " + this.skipped_after_array.length + " Observations",
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
                text: "Percent",
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
                  if (tooltipItem.datasetIndex == 0) {
                    return "Moving Avg: " + tooltipItem.raw;
                  } else if (tooltipItem.datasetIndex == 1) {
                    return "Actual Skipped After Slots: " + tooltipItem.raw;
                  } else {
                    return "Cluster Avg: " + tooltipItem.raw;
                  }
                },
                title: function(tooltipItem) {
                  return tooltipItem[0].label + " UTC";
                },
              }
            },
            legend: {
              labels: {
                color: chart_variables.chart_darkgrey,
                boxWidth: chart_variables.chart_legend_box_size,
                boxHeight: chart_variables.chart_legend_box_size,
                usePointStyle: true,
                padding: 5,
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
          <h2 class="h4 card-heading mb-3">Skipped After History</h2>
        </div>
        <div class="pb-3 px-3">
          <canvas id="skipped-after-history"></canvas>
        </div>
      </div>
    </div>
`
}
