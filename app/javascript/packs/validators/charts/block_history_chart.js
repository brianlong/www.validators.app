import Chart from 'chart.js/auto'
import chart_variables from './chart_variables'

export default {
  props: {
    root_blocks: {
        type: Array,
        required: true
    }
  },
  data() {
    return {
      default_score_class: "fas fa-circle me-1 score-"
    }
  },
  mounted(){
    var ctx = document.getElementById("root-distance-history").getContext('2d');

    var chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.labels(),
        datasets: [
          {
            label: ' Block Diff ',
            fill: true,
            borderColor: chart_variables.chart_purple_2,
            backgroundColor: chart_variables.chart_purple_2_t,
            borderWidth: 1,
            radius: 0,
            data: this.root_blocks,
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
            gridLines: { display: false },
            title: {
              display: true,
              text: "Previous " + this.root_blocks.length + " Observations",
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
              zeroLineColor: chart_variables.chart_grid_color,
              color: chart_variables.chart_grid_color
            },
            title: {
              display: true,
              text: "Dist Behind Leader",
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
                return "Distance: " + tooltipItem.raw.y;
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
        }
      }]
    });
  },
  methods: {
    labels() {
      let labels = []
      this.root_blocks.forEach(function(val){
        labels.push(val['x'])
      })
      return labels
    }
  },
  template: `
    <div class="col-lg-6">
      <div class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h4 card-heading mb-3">Block History</h2>
        </div>
        <div class="pb-3 px-3">
          <canvas id="root-distance-history"></canvas>
        </div>
      </div>
    </div>
`
}
