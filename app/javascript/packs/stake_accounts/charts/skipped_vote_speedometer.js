import chart_vars from './chart_variables'

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
        return chart_vars.chart_green
      } else if(val == 1) {
        return chart_vars.chart_blue
      }
      return chart_vars.chart_lightgrey
    },
    chart_fill_color(val) {
      if (val == 2) {
        return chart_vars.chart_green_t
      } else if(val == 1) {
        return chart_vars.chart_blue_t
      }
      return chart_vars.chart_lightgrey_t
    },
    max_value_position(vector, min_position = true) {
      var max_value = Math.max.apply(Math, vector)
      var max_value_index = vector.indexOf(max_value) + 1
      var position = max_value_index.to_f / vector.size * 100
      position += 3
      position = Math.min.apply(Math, [position, 100])
      if (min_position){
        position = Math.max.apply(Math, [position, 100])
      }
      return position
    },
    skipped_vote_percent() {
      if (this.validator['skipped_vote_history'] && this.batch['best_skipped_vote']){
        var skipped_votes_percent = this.validator['skipped_vote_history'][-1]
        
        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).round(2) : null
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
                value: Math.min.apply(Math, [this.skipped_vote_percent(), this.batch['skipped_vote_all_median'] * 3]),
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
    <td class="column-sm align-middle">
      <div v-if="skipped_vote_percent">
        <div class="d-none d-lg-block">
          <canvas :id=" 'spark_line_skipped_vote_' + validator['account'] " width="5%"></canvas>
          <div class="text-center text-muted small mt-2">
            {{ skipped_vote_percent() }}
          </div>
        </div>
        <span class="d-inline-block d-lg-none">
          Skipped Vote&nbsp;%:
          {{ skipped_vote_percent() || 'N/A' }}
        </span>
      </div>
    </td>
  `
}
