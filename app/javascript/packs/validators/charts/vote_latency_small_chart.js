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
    if(this.validator && this.validator['vote_latency_history'] && this.validator['vote_latency_history'].length > 0) {
      var vote_latency_vl = Math.min.apply(Math, [60, this.validator['vote_latency_history'].length]);
      var vote_latency_vector = this.validator['vote_latency_history'].slice(Math.max(this.validator['vote_latency_history'].length - vote_latency_vl, 0));
      var max_value = Math.max.apply(Math, vote_latency_vector);
      var max_value_position = this.$parent.max_value_position(vote_latency_vector);
      return {
        max_value: max_value,
        max_value_position: max_value_position,
        y_root_distance_max: 3,
        vote_latency_chart: {
          line_color: this.$parent.chart_line_color(this.validator['vote_latency_score']),
          fill_color: this.$parent.chart_fill_color(this.validator['vote_latency_score']),
          vector: vote_latency_vector
        },
      }
    }
    else {
      return {}
    }
  },

  mounted: function () {
    var vote_latency_el = document.getElementById("spark_line_vote_latency_" + this.validator['account']).getContext('2d');
    new Chart(vote_latency_el, {
      type: 'line',
      data: {
        labels: Array.from(Array(this.vote_latency_chart['vector'].length).keys()).reverse(),
        datasets: [
          {
            fill: true,
            borderColor: this.vote_latency_chart['line_color'],
            backgroundColor: this.vote_latency_chart['fill_color'],
            borderWidth: 1,
            radius: 0,
            data: this.vote_latency_chart['vector'],
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
            title: { display: false }
          },
          y: {
            display: true,
            min: 0,
            max: this.y_root_distance_max,
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
          tooltip: { display: false },
          legend: { display: false }
        },
      }
    });
  },
  template: `
    <td class="column-chart d-none d-lg-table-cell" :id="'vote-latency-' + idx ">
      <div class="chart-top-container" v-if="validator && validator['vote_latency_history'] && validator['vote_latency_history'].length > 0 && max_value > 20">
        <div class="chart-top-value"
             :style="{ left: max_value_position }">
          {{ max_value }}
        </div>
      </div>
      
      <canvas :id=" 'spark_line_vote_latency_' + validator['account'] " v-if="validator && validator['vote_latency_history'] && validator['vote_latency_history'].length > 0"></canvas>
      <span v-else class="text-muted"> N/A </span>
    </td>
  `
}
