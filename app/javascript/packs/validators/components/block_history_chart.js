import Chart from 'chart.js/auto'

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
            borderColor: "rgb(221, 154, 229)",
            backgroundColor: "rgba(221, 154, 229, 0.4)",
            borderWidth: 1,
            radius: 0,
            data: this.root_blocks,
            tension: 0
          }
        ]
      },
      options: {
        hover: {
          intersect: false,
        },
        tooltips: {
          enabled: true,
          intersect: false,
          mode: 'index',
          displayColors: false,
          xPadding: 8,
          yPadding: 8,
          callbacks: {
            label: function(tooltipItem) {
              return "Distance: " + tooltipItem.yLabel;
            },
            title: function(tooltipItem) {
              return tooltipItem[0].xLabel + " UTC";
            },
          }
        },
        responsiveAnimationDuration: 0, // animation duration after a resize
          legend: {
            labels: {
              fontColor: '#979797',
              boxWidth: 8,
              boxHeight: 8,
              usePointStyle: true,
              padding: 5,
              fontSize: 14
            },
          },
          scales: {
            xAxes: [{
              display: true,
              ticks: {
                display: true,
                minRotation: 0,
                maxRotation: 0,
                autoSkip: true,
                autoSkipPadding: 30
              },
              gridLines: { display: false },
              scaleLabel: {
                display: true,
                labelString: "Previous Observations",
                fontColor: '#979797'
              }
            }],
            yAxes: [{
              display: true,
              ticks: {
                min: 0,
                padding: 5
              },
              gridLines: {
                display: true,
                zeroLineColor: '#322f3d',
                color: '#322f3d'
              },
              scaleLabel: {
                display: true,
                labelString: "Dist Behind Leader",
                fontColor: '<%= #979797 %>'
              }
            }]
          }
        },
        plugins: {
          beforeInit(chart) {
            const originalFit = chart.legend.fit;
            chart.legend.fit = function fit() {
              originalFit.bind(chart.legend)();
              this.height += 12;
            }
          },
        }
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
