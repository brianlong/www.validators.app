import Chart from 'chart.js/auto';
import chart_variables from './chart_variables'
import '../../mixins/validators_mixins'

export default {
  props: {
    validator: {
      type: Object,
      required: true
    },
    batch: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      skipped_vote_percent_val: null
    }
  },

  methods: {
    set_needle_position(needle_value) {
      let single_range_size = this.batch['skipped_vote_all_median'];
      if(!needle_value || !single_range_size) {
        return 0;
      }
      let chart_maximum = single_range_size*3;
      let value_in_percents = (needle_value / chart_maximum) * 100;
      value_in_percents = Math.min.apply(Math, [value_in_percents, 100]).toFixed(2);
      return (100 - value_in_percents);
    }
  },

  mounted: function () {
    this.skipped_vote_percent_val = this.skipped_vote_percent(this.validator, this.batch);
    let speedometer = document.getElementById("spark_line_skipped_vote_" + this.validator['account']).getContext('2d');
    new Chart(speedometer, {
      type: 'doughnut',
      data: {
        datasets: [{
          data: [33.33, 33.33, 33.33],
          needleValue: this.set_needle_position(skipped_vote_percent_val),
          backgroundColor: [
            chart_variables.chart_lightgrey_speedometer,
            chart_variables.chart_blue_speedometer,
            chart_variables.chart_green_speedometer
          ],
          borderColor: [
            chart_variables.chart_lightgrey,
            chart_variables.chart_blue,
            chart_variables.chart_green
          ],
          borderWidth: 1
        }]
      },
      options: {
        rotation: 270,
        circumference: 180,
        cutout: 18,
        aspectRatio: 2,
        plugins: {
          tooltip: { enabled: false },
          legend: { display: false },
        }
      },
      plugins: [{
        afterDatasetDraw(chart, args, options) {
          const { ctx, config, data, chartArea: { top, bottom, left, right, width, height } } = chart;
          ctx.save();

          const dataTotal = 100; // total width of data - in our case 100%
          let needleValue = data.datasets[0].needleValue;
          let needleAngle = Math.PI + ( 1 / dataTotal * needleValue * Math.PI);
          // find the bottom center of chart
          let chart_x = width / 2;
          let chart_y = chart._metasets[0].data[0].y;
          // set needle width
          let needleWidth = width / 2 - 10;

          // draw needle (triangle)
          ctx.translate(chart_x, chart_y); // set starting point
          ctx.rotate(needleAngle); // rotate towards destination point
          ctx.beginPath(); // start drawing
          ctx.moveTo(0, -3); // move 2px to the left
          ctx.lineTo(needleWidth, 0); // draw a line
          ctx.lineTo(0, 3); // go to 2px to the right from starting point
          ctx.lineTo(0, -3); // go back to starting point
          ctx.fillStyle = chart_variables.chart_lightgrey_speedometer_needle; // set color
          ctx.strokeStyle = chart_variables.chart_lightgrey_speedometer_needle;
          ctx.lineWidth = 1;
          ctx.stroke(); // draw triangle borders
          ctx.fill(); // fill triangle with color

          ctx.restore();
        }
      }]
    });
  },

  template: `
    <td class="column-speedometer">
      <div v-if="skipped_vote_percent_val">
        <div class="d-none d-lg-block">
          <canvas :id="'spark_line_skipped_vote_' + validator['account']"></canvas>
          <div class="text-center text-muted small mt-2">
            {{ skipped_vote_percent_string(skipped_vote_percent_val) }}
          </div>
        </div>
        
        <span class="d-inline-block d-lg-none small">
          Skipped Vote&nbsp;%:&nbsp;
          {{ skipped_vote_percent_string(skipped_vote_percent_val) }}
        </span>
      </div>
    </td>
  `
}
