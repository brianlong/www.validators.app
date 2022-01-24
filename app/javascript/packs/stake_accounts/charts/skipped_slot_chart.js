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
    var skipped_slots_vl = Math.min.apply(Math, [60, this.validator['skipped_slot_history'].length])
    var skipped_slots_ma = Math.min.apply(Math, [60, this.validator['skipped_slot_moving_average_history'].length])
    var skipped_slots_ma_vector = this.validator['skipped_slot_moving_average_history'].slice(Math.max(this.validator['skipped_slot_moving_average_history'].length - skipped_slots_ma, 0))
    var skipped_slots_vector = this.validator['skipped_slot_history'].slice(Math.max(this.validator['skipped_slot_history'].length - skipped_slots_vl, 0))
    skipped_slots_vector.forEach(function(part, index) {
      this[index] = part * 100;
    }, skipped_slots_vector)
    skipped_slots_ma_vector.forEach(function(part, index) {
      this[index] = part * 100;
    }, skipped_slots_ma_vector)
    return {
      y_root_distance_max: 20,
      skipped_slots_distance_chart: {
        vl: skipped_slots_vl,
        line_color: this.chart_line_color(this.validator['skipped_slot_score']),
        fill_color: this.chart_fill_color(this.validator['skipped_slot_score']),
        vector: skipped_slots_vector,
        moving_avg: skipped_slots_ma_vector
      }
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
    var skipped_slots_el = document.getElementById("spark_line_skipped_slots_" + this.validator['account']).getContext('2d');
    new Chart(skipped_slots_el, {
        type: 'line',
        data: {
            labels: Array.from(Array(this.skipped_slots_distance_chart['vector'].length).keys()).reverse(),
            datasets: [
                {
                    label: 'Skip %',
                    fill: false,
                    borderColor: this.skipped_slots_distance_chart['line_color'],
                    borderWidth: 1,
                    borderDash: [2, 2],
                    radius: 0,
                    data: this.skipped_slots_distance_chart['vector']
                },
                {
                    label: '24h Moving Avg Skip %',
                    fill: false,
                    borderColor: this.skipped_slots_distance_chart['line_color'],
                    borderWidth: 1,
                    radius: 0,
                    data: this.skipped_slots_distance_chart['moving_avg']
                }
            ]
        },

        // Configuration options go here
        options: {
            animation: { duration: 0 }, // general animation time
            elements: { line: { tension: 0 } }, // disables bezier curves
            hover: { mode: null },
            tooltips: { enabled: false },
            responsiveAnimationDuration: 0, // animation duration after a resize
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
                        beginAtZero: false,
                        padding: 3,
                        fontColor: chart_vars.chart_lightgrey
                    },
                    gridLines: {
                        display: true,
                        zeroLineColor: 'transparent'
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
    <td class="column-chart d-none d-lg-table-cell align-middle pt-lg-3" :id="'skipped-slots-' + idx ">
      <canvas :id=" 'spark_line_skipped_slots_' + validator['account'] " width="5%"></canvas>
    </td>
  `
}
