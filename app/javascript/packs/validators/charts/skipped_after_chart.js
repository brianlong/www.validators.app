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
    var skipped_after_history_vl = Math.min.apply(Math, [60, this.validator['skipped_after_history'].length]);
    var skipped_after_history_vector = this.validator['skipped_after_history'].slice(Math.max(this.validator['skipped_after_history'].length - skipped_after_history_vl, 0));
    skipped_after_history_vector = skipped_after_history_vector.map(function (x) { return x * 100 });
    var max_value = Math.max.apply(Math, skipped_after_history_vector);
    var max_value_position = this.$parent.max_value_position(skipped_after_history_vector);
    return {
      max_value: max_value,
      max_value_position: max_value_position,
      skipped_after_history_chart: {
        line_color: this.$parent.chart_line_color(this.validator['skipped_after_score']),
        fill_color: this.$parent.chart_fill_color(this.validator['skipped_after_score']),
        vector: skipped_after_history_vector
      },
    }
  },

  mounted: function () {
    var block_distance_el = document.getElementById("spark_line_skipped_after_" + this.validator['account']).getContext('2d');
    new Chart(block_distance_el, {
      type: 'line',
      data: {
        labels: Array.from(Array(this.skipped_after_history_chart['vector'].length).keys()).reverse(),
        datasets: [
          {
            fill: true,
            borderColor: this.skipped_after_history_chart['line_color'],
            backgroundColor: this.skipped_after_history_chart['fill_color'],
            borderWidth: 1,
            radius: 0,
            data: this.skipped_after_history_chart['vector'],
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
            min: 0,
            max: chart_variables.chart_y_max,
            ticks: {
              color: chart_variables.chart_darkgrey,
              font: {
                size: chart_variables.chart_font_size,
              }
            },
            grid: { display: false },
            title: { display: false }
          }
        },
        plugins: {
          tooltip: { display: false },
          legend: { display: false }
        },
      }
    });
  },
  template: `
    <td class="column-chart d-none d-lg-table-cell" :id="'skipped-after-' + idx ">
      <div class="chart-top-container" v-if="max_value > 20">
        <div class="chart-top-value"
             :style="{ left: max_value_position }">
          {{ max_value }}
        </div>
      </div>
    
      <canvas :id=" 'spark_line_skipped_after_' + validator['account'] "></canvas>
    </td>
  `
}
