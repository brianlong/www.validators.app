import Chart from 'chart.js/auto'

export default {
  props: {
    vote_blocks: {
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
    var ctx = document.getElementById("vote-distance-history").getContext('2d');

    var chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.labels(),
        datasets: [
          {
            label: ' Block Diff ',
            fill: true,
            borderColor: "rgb(221, 154, 229)",
            backgroundColor: "rgba(221, 154, 229, 0.4)",
            borderWidth: 1,
            radius: 0,
            data: this.vote_blocks,
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
              text: "Previous " + this.vote_blocks.length + " Observations",
              color: '#979797'
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
              zeroLineColor: '#322f3d',
              color: '#322f3d'
            },
            title: {
              display: true,
              text: "Dist Behind Leader",
              color: '#979797'
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
              boxWidth: 8,
              boxHeight: 8,
              usePointStyle: true,
              padding: 10,
              color: '#979797',
              font: {
                size: 14
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
  },
  methods: {
    labels() {
      let labels = []
      this.vote_blocks.forEach(function(val){
        labels.push(val['x'])
      })
      return labels
    }
  },
  template: `
    <div class="col-lg-6">
      <div class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h4 card-heading mb-3">Vote History</h2>
        </div>
        <div class="pb-3 px-3">
          <canvas id="vote-distance-history"></canvas>
        </div>
      </div>
    </div>
`
}
