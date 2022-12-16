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

  data() {
    var vote_distance_vl = Math.min.apply(Math, [60, this.validator['vote_distance_history'].length]);
    var vote_distance_vector = this.validator['vote_distance_history'].slice(Math.max(this.validator['vote_distance_history'].length - vote_distance_vl, 0));
    var max_value = Math.max.apply(Math, vote_distance_vector);
    var max_value_position = this.$parent.max_value_position(vote_distance_vector);
    return {
      max_value: max_value,
      max_value_position: max_value_position,
      y_root_distance_max: 20,
      vote_distance_chart: {
        vl: vote_distance_vl,
        line_color: this.chart_line_color(this.validator['vote_distance_score']),
        fill_color: this.chart_fill_color(this.validator['vote_distance_score']),
        vector: vote_distance_vector
      },
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
  },

  mounted: function () {
    var vote_distance_el = document.getElementById("spark_line_vote_distance_" + this.validator['account']).getContext('2d');
    new Chart(vote_distance_el, {
        type: 'line',
        data: {
            labels: Array.from(Array(this.vote_distance_chart['vector'].length).keys()).reverse(),
            datasets: [
                {
                    label: '',
                    fill: true,
                    borderColor: this.vote_distance_chart['line_color'],
                    backgroundColor: this.vote_distance_chart['fill_color'],
                    borderWidth: 1,
                    radius: 0,
                    data: this.vote_distance_chart['vector']
                }
            ]
        },
        options: {
            animation: false,
            hover: { mode: null },
            scales: {
                x: {
                    display: true,
                    ticks: { display: false },
                    grid: { display: false },
                    title: { display: false, }
                },
                y: {
                    display: true,
                    min: 0,
                    max: chart_vars.chart_y_max,
                    ticks: {
                        padding: 3,
                        color: chart_vars.chart_darkgrey,
                        font: {
                            size: chart_vars.chart_font_size,
                        }
                    },
                    grid: { display: false, },
                    text: { display: false, }
                }
            },
            elements: {
                line: { tension: 0 }
            },
            plugins: {
                legend: { display: false },
                tooltips: { enabled: false },
            }
        }
    });
  },

  template: `
    <td class="column-chart d-none d-lg-table-cell" :id="'vote-distance-' + idx ">
      <div class="chart-top-container" v-if="max_value > 20">
        <div class="chart-top-value"
             :style="{ left: max_value_position }">
          {{ max_value }}
        </div>
      </div>
      
      <canvas :id=" 'spark_line_vote_distance_' + validator['account'] "></canvas>
    </td>
  `
}
