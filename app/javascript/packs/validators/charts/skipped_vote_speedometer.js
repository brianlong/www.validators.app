import chart_variables from './chart_variables'

export default {
  props: {
    validator: {
      type: Object,
      required: true
    },
    idx: {
      type: Number,
      required: true
    },
    batch: {
      type: Object,
      required: true
    }
  },
  methods: {
    chart_line_color(val) {
      if (val == 2) {
        return chart_variables.chart_green
      } else if(val == 1) {
        return chart_variables.chart_blue
      }
      return chart_variables.chart_lightgrey
    },
    chart_fill_color(val) {
      if (val == 2) {
        return chart_variables.chart_green_t
      } else if(val == 1) {
        return chart_variables.chart_blue_t
      }
      return chart_variables.chart_lightgrey_t
    },
    skipped_vote_percent() {
      if (this.validator['skipped_vote_history'] && this.batch['best_skipped_vote']){
        var history_array = this.validator['skipped_vote_history']
        var skipped_votes_percent = history_array[history_array.length - 1]
        return skipped_votes_percent ? ((this.batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).toFixed(2) : null
      } else {
        return null
      }
    }
  },
  mounted: function () {
    var speedometer = document.getElementById("spark_line_skipped_vote_" + this.validator['account']).getContext('2d');
    new Chart(speedometer, {
        type: 'gauge',
        data: {
            datasets: [{
                data: [this.batch['skipped_vote_all_median'] * 2, this.batch['skipped_vote_all_median'], 0.05],
                value: Math.max.apply(Math, [this.skipped_vote_percent(), this.batch['skipped_vote_all_median'] * 3]),
                minValue: this.batch['skipped_vote_all_median'] * 3,
                maxValue: 0.05,
                backgroundColor: [
                  'rgba(202, 202, 202, 0.45)',
                  'rgba(0, 145, 242, 0.4)',
                  'rgba(0, 206, 153, 0.55)'
                ],
                borderColor: ['#cacaca', '#0091f2', '#00ce99'],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            title: {
                display: false
            },
            layout: {
                padding: {
                    left: 0,
                    right: 0
                }
            },
            needle: {
                radiusPercentage: 0,
                widthPercentage: 5,
                lengthPercentage: 80,
                color: '#979797'
            },
            valueLabel: {
                display: false
            }
        }
    });
  },
  template: `
    <td class="column-speedometer">
      <div v-if="skipped_vote_percent">
        <div class="d-none d-lg-block">
          <canvas :id="'spark_line_skipped_vote_' + validator['account'] " v-if="skipped_vote_percent()"></canvas>
          <div class="text-center text-muted small mt-2">
            {{ skipped_vote_percent() ? skipped_vote_percent() + "%" : "N / A" }}
          </div>
        </div>
        
        <span class="d-inline-block d-lg-none">
          Skipped Vote&nbsp;%:
          {{ skipped_vote_percent() ? skipped_vote_percent() + "%" : "N / A" }}
        </span>
      </div>
    </td>
  `
}
