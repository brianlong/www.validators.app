import Chart from 'chart.js/auto'
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
  },

  methods: {},

  data() {
    if(this.validator && this.validator['skipped_slot_history'] && this.validator['skipped_slot_history'].length > 0) {
      var skipped_slots_vl = Math.min.apply(Math, [60, this.validator['skipped_slot_history'].length])
      if(this.validator['skipped_slot_moving_average_history']){
        var skipped_slots_ma = Math.min.apply(Math, [60, this.validator['skipped_slot_moving_average_history'].length])
        var skipped_slots_ma_vector = this.validator['skipped_slot_moving_average_history'].slice(Math.max(this.validator['skipped_slot_moving_average_history'].length - skipped_slots_ma, 0))
      } else {
        var skipped_slots_ma_vector = []
      }
      var skipped_slots_vector = this.validator['skipped_slot_history'].slice(Math.max(this.validator['skipped_slot_history'].length - skipped_slots_vl, 0))
      skipped_slots_vector.forEach(function(part, index) {
        this[index] = part * 100;
      }, skipped_slots_vector)
      skipped_slots_ma_vector.forEach(function(part, index) {
        this[index] = part * 100;
      }, skipped_slots_ma_vector)
      return {
        skipped_slots_distance_chart: {
          line_color: this.$parent.chart_line_color(this.validator['skipped_slot_score']),
          fill_color: this.$parent.chart_fill_color(this.validator['skipped_slot_score']),
          vector: skipped_slots_vector,
          moving_avg_vector: skipped_slots_ma_vector
        }
      }
    } else {
      return {}
    }
  },

  mounted: function () {
    if(this.validator && this.validator['skipped_slot_history'] && this.validator['skipped_slot_history'].length > 0) {
      var skipped_slots_el = document.getElementById("spark_line_skipped_slots_" + this.validator['account']).getContext('2d');
      new Chart(skipped_slots_el, {
        type: 'line',
        data: {
          labels: Array.from(Array(this.skipped_slots_distance_chart['vector'].length).keys()).reverse(),
          datasets: [
            {
              fill: false,
              borderColor: this.skipped_slots_distance_chart['line_color'],
              borderWidth: 1,
              borderDash: [2, 2],
              radius: 0,
              data: this.skipped_slots_distance_chart['vector'],
              tension: 0
            },
            {
              fill: false,
              borderColor: this.skipped_slots_distance_chart['line_color'],
              borderWidth: 1,
              radius: 0,
              data: this.skipped_slots_distance_chart['moving_avg_vector'],
              tension: 0
            }
          ]
        },

        options: {
          scales: {
            x: {
              display: true,
              ticks: { display: false },
              grid: { display: false },
              title: { display: false },
            },
            y: {
              display: true,
              ticks: {
                color: chart_variables.chart_darkgrey,
                font: {
                  size: chart_variables.chart_font_size,
                },
              },
              grid: { display: false },
              title: { display: false }
            }
          },
          plugins: {
            tooltip: { enabled: false },
            legend: { display: false }
          },
        }
      });
    }
  },
  template: `
    <td class="column-chart d-none d-lg-table-cell text-center" :id="'skipped-slots-' + idx ">
      <canvas :id=" 'spark_line_skipped_slots_' + validator['account'] " v-if="validator && validator['skipped_slot_history'] && validator['skipped_slot_history'].length > 0"></canvas>
      <span v-else class="text-muted"> N/A </span>
    </td>
  `
}
