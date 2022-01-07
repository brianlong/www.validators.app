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
    }
  },
  data() {
    var root_distance_vl = Math.max.apply(Math, [60, this.validator['root_distance_history'].length])
    var root_distance_vector = this.validator['root_distance_history'].slice(Math.max(this.validator['root_distance_history'].length - root_distance_vl, 0))
    return {
      y_root_distance_max: 20,
      root_distance_chart: {
        vl: root_distance_vl,
        line_color: this.chart_line_color(this.validator['root_distance_score']),
        fill_color: this.chart_fill_color(this.validator['root_distance_score']),
        vector: root_distance_vector,
        max_value: Math.max.apply(Math, root_distance_vector),
        max_value_position: this.max_value_position(root_distance_vector),
        max_value_position_mobile: this.max_value_position(root_distance_vector, false)
      },
    }
  },
  mounted: function () {
    var block_distance_el = document.getElementById("spark_line_block_distance_" + this.validator['account']).getContext('2d');
    new Chart(block_distance_el, {
        type: 'line',
        data: {
            labels: Array.from(Array(this.root_distance_chart['vector'].length).keys()).reverse(),
            datasets: [
                {
                    label: 'Block Diff',
                    fill: true,
                    borderColor: this.root_distance_chart['line_color'],
                    backgroundColor: this.root_distance_chart['fill_color'],
                    borderWidth: 1,
                    radius: 0,
                    data: this.root_distance_chart['vector']
                }
            ]
        },
        options: {
            animation: { duration: 0 },
            elements: { line: { tension: 0 } },
            hover: { mode: null },
            tooltips: { enabled: false },
            responsiveAnimationDuration: 0,
            legend: { display: false },
            scales: {
                xAxes: [{
                    display: true,
                    ticks: { display: false },
                    gridLines: { display: false },
                    scaleLabel: {
                        display: false,
                        labelString: ''
                    }
                }],
                yAxes: [{
                    display: true,
                    ticks: {
                        min: 0,
                        padding: 3,
                        fontColor: chart_vars.chart_lightgrey,
                        max: this.y_root_distance_max
                    },
                    gridLines: {
                        display: false,
                        zeroLineColor: '#322f3d'
                    },
                    scaleLabel: {
                        display: false,
                        labelString: ''
                    }
                }]
            }
        }
    });
  },
  template: `
    <td class="column-chart d-none d-lg-table-cell align-middle" :id="' root-distance-' + idx ">
    <div class="chart-top-container" v-if="root_distance_chart['max_value'] && root_distance_chart['max_value'] > y_root_distance_max">
      <div class="chart-top-value d-lg-none" :style=" 'width: ' + root_distance_chart['max_value_position_mobile']">
        {{ root_distance_chart['max_value_position'] }}
      </div>
      <div class="chart-top-value d-none d-lg-block" :style=" 'width: ' + root_distance_chart['max_value_position']">
        {{ root_distance_chart['max_value'] }}
      </div>
    </div>
    <canvas :id=" 'spark_line_block_distance_' + validator['account'] " width="5%"></canvas>
  </td>
  `
}