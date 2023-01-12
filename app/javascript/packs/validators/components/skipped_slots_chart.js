import Chart from 'chart.js/auto'

export default {
  props: {
    skipped_slots: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      default_score_class: "fas fa-circle me-1 score-"
    }
  },
  mounted(){
    var ctx = document.getElementById("skipped-slots-history").getContext('2d');

    var skipped_slot_percent_moving_average = this.skipped_slots_array.map( (vector_element, index) => (
      vector_element['skipped_slot_percent_moving_average']
    ))
    var skipped_slot_percent = this.skipped_slots_array.map( (vector_element, index) => (
      vector_element['skipped_slot_percent']
    ))
    var cluster_skipped_slot_percent_moving_average = this.skipped_slots_array.map( (vector_element, index) => (
      vector_element['cluster_skipped_slot_percent_moving_average']
    ))

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.labels(),
        datasets: [
          {
            label: ' Moving Avg  ',
            fill: false,
            backgroundColor: 'rgba(239, 206, 243, 0.4)',
            borderColor: 'rgb(239, 206, 243)',
            borderWidth: 1,
            radius: 0,
            data: skipped_slot_percent_moving_average
          },
          {
            label: ' Actual Skipped Slots  ',
            fill: false,
            backgroundColor: 'rgba(221, 154, 229, 0.4)',
            borderColor: 'rgb(221, 154, 229)',
            borderWidth: 1,
            borderDash: [2, 2],
            radius: 0,
            data: skipped_slot_percent
          },
          {
            label: ' Cluster Avg',
            fill: false,
            backgroundColor: 'rgba(170, 46, 184, 0.4)',
            borderColor: 'rgb(170, 46, 184)',
            borderWidth: 1,
            radius: 0,
            data: cluster_skipped_slot_percent_moving_average
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
              text: "Previous " + cluster_skipped_slot_percent_moving_average.length + " Observations",
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
              text: "Percent",
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
                if (tooltipItem.datasetIndex == 0) {
                  return "Moving Avg: " + tooltipItem.raw;
                } else if (tooltipItem.datasetIndex == 1) {
                  return "Actual Skipped Slots: " + tooltipItem.raw;
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
              color: '#979797',
              boxWidth: 8,
              boxHeight: 8,
              usePointStyle: true,
              padding: 5,
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
  computed: {
    skipped_slots_array() {
      let arr = []
      for (const [key, value] of Object.entries(this.skipped_slots)) {
        arr.push(value)
      }
      return arr
    }
  },
  methods: {
    labels() {
      let labels = []
      this.skipped_slots_array.forEach(function(val){
        labels.push(val['label'])
      })
      return labels
    }
  },
  template: `
    <div class="col-lg-6">
      <div class="card mb-4">
        <div class="card-content pb-0">
          <h2 class="h4 card-heading mb-3">Skipped Slots History</h2>
        </div>
        <div class="pb-3 px-3">
          <canvas id="skipped-slots-history"></canvas>
        </div>
      </div>
    </div>
`
}
