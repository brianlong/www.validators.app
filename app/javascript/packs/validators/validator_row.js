import Vue from '../shared/vue_setup'
import '../mixins/stake_pools_mixins'
import '../mixins/numbers_mixins'
import '../mixins/validators_mixins'

import chart_variables from './charts/chart_variables'
import rootDistanceChart from './charts/root_distance_chart'
import voteDistanceChart from './charts/vote_distance_chart'
import skippedSlotsChart from './charts/skipped_slots_small_chart'
import voteLatencyChart from './charts/vote_latency_small_chart'

import scores from './components/scores'

const ValidatorRow = {
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

  components: {
    'root-distance-chart': rootDistanceChart,
    'vote-distance-chart': voteDistanceChart,
    'skipped-slots-chart': skippedSlotsChart,
    'vote-latency-chart': voteLatencyChart,
    "validator-scores": scores
  },

  created() {
    this.validator['displayed_total_score'] = this.displayed_total_score()
  },

  methods: {
    row_index() {
      return 'row-' + this.idx
    },

    is_validator_private() {
      return this.validator['commission'] === 100 && this.validator['network'] === 'mainnet'
    },

    displayed_validator_name() {
      if(this.is_validator_private()) {
        return "Private Validator"
      } else {
        return this.shortened_validator_name(this.validator["name"], this.validator["account"])
      }
    },

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

    display_chart(target, event) {
      let i = this.idx;
      let target_tag = document.getElementById(target+"-"+i);
      let row = document.getElementById("row-"+i);

      if(!target_tag.classList.contains("d-none")) {
        // Hide the chart if selected chart is already shown
        target_tag.classList.add("d-none");
        event.target.classList.remove("active");
      } else {
        // Otherwise show the selected chart and hide the rest
        row.querySelectorAll(".column-chart").forEach(chart => {
          chart.classList.add("d-none");
        })
        target_tag.classList.remove("d-none");

        // Set active link
        row.querySelectorAll(".chart-link").forEach(l => {
          l.classList.remove("active")
        });
        event.target.classList.add("active");
      }
    },

    // Set max_value position for root & vote distance charts
    max_value_position(vector) {
      var max_value = Math.max.apply(Math, vector);
      var max_value_index = vector.indexOf(max_value).toFixed(2);
      var vector_length = vector.length.toFixed(2);
      var position = (max_value_index / vector_length * 100).toFixed(0);
      position = Math.max.apply(Math, [position, 2])
      // set max position for large numbers
      if (max_value > 100000) {
        position = Math.min.apply(Math, [position, 70])
      } else if(max_value > 10000) {
        position = Math.min.apply(Math, [position, 80])
      }
      return position + "%";
    },

    displayed_total_score() {
      if(this.validator["commission"] == 100 && this.validator["network"] == 'mainnet') {
        return 'N/A'
      } else if(this.validator["admin_warning"]) {
        return 'N/A'
      } else {
        return this.validator["total_score"]
      }
    },
  },

  template: `
    <tr :id="row_index()">
      <td class="column-info">
        <div class="column-info-row" data-turbolinks=false>
          <div class="column-info-avatar">
            <div class="img-circle-large-private" v-if="is_validator_private()">
              <span class="fa-solid fa-users-slash" title="Private Validator"></span>
            </div>
            <img :src="avatar_url(this.validator)" class='img-circle-large' v-else />
          </div>

          <div class="column-info-name">
            <a :href="validator_url(this.validator['account'], this.validator['network'])" class="column-info-link no-watchlist fw-bold">
              {{ displayed_validator_name() }}
              <small class="text-muted text-nowrap fw-normal" v-if="!is_validator_private()">
                (<span class="d-inline-block d-lg-none">Comm.:&nbsp;</span>{{ validator["commission"] }}%)
              </small>
            </a>
            <br />
            <validator-scores class="d-inline-block" :score="validator" :account="validator['account']"></validator-scores>

            <div class="mt-2 mt-lg-0 small">
              <div class="d-lg-inline-block">
                <span class="d-inline-block d-lg-none">Active Stake:&nbsp;</span>
                <span class="me-2">
                {{ lamports_to_sol(validator['active_stake']).toLocaleString('en-US', { maximumFractionDigits: 0 }) }}&nbsp;SOL
              </span>
              </div>
              <div class="d-lg-inline-block">
                <span class="d-inline-block d-lg-none">Software Version:&nbsp;</span>
                <span class="d-none d-lg-inline-block">V:&nbsp;</span>
                {{ validator['software_version'] }}
              </div>
            </div>
          </div>
        </div>

        <div class="mt-2" v-if="validator['authorized_withdrawer_score']== -2 || validator['admin_warning'] || validator['delinquent']">
          <small v-if="validator['delinquent']" class="text-danger me-2">delinquent</small>
          <a v-if="validator['authorized_withdrawer_score']== -2" href="/faq#withdraw-authority-warning" title="Withdrawer matches validator identity.">
            <small class="text-warning me-2">withdrawer</small>
          </a>
          <a href="/faq#admin-warning" v-if="validator['admin_warning']" :title="validator['admin_warning']" >
            <small class="text-danger">warning</small>
          </a>
        </div>
      </td>

      <!-- Charts menu -->
      <td class="d-lg-none pt-2">
        <div class="row small mb-3">
          <div class="col pe-0">
            <a class="chart-link" :data-iterator="idx" @click.prevent="display_chart('root-distance', $event)" href="">
              Root <br class="d-xxs-inline-block" />Distance
            </a>
          </div>
          <div class="col pe-0">
            <a class="chart-link" :data-iterator="idx" @click.prevent="display_chart('vote-distance', $event)" href="">
              Vote <br class="d-xxs-inline-block" />Distance
            </a>
          </div>
          <div class="col">
            <a class="chart-link" :data-iterator="idx" @click.prevent="display_chart('skipped-slots', $event)" href="">
              Skipped <br class="d-xxs-inline-block" />Slots
            </a>
          </div>
          <div class="col">
            <a class="chart-link" :data-iterator="idx" @click.prevent="display_chart('vote-latency', $event)" href="">
              Vote <br class="d-xxs-inline-block" />Latency
            </a>
          </div>
        </div>
      </td>

      <root-distance-chart :validator="validator" :idx="idx" />

      <vote-distance-chart :validator="validator" :idx="idx" />

      <skipped-slots-chart :validator="validator" :idx="idx" />

      <vote-latency-chart :validator="validator" :idx="idx" />

    </tr>
  `
}

export default ValidatorRow
