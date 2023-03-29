import Vue from 'vue/dist/vue.esm'
import '../mixins/stake_pools_mixins';

import chart_variables from './charts/chart_variables'
import rootDistanceChart from './charts/root_distance_chart'
import voteDistanceChart from './charts/vote_distance_chart'
import skippedSlotsChart from './charts/skipped_slots_small_chart'
import skippedVoteSpeedometer from './charts/skipped_vote_speedometer'

import scores from './components/scores'

var ValidatorRow = Vue.component('validatorRow', {
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
    'skipped-vote-speedometer': skippedVoteSpeedometer,
    "validator-scores": scores
  },

  created() {
    this.validator['displayed_total_score'] = this.displayed_total_score()
  },

  methods: {
    create_avatar_link() {
      if(this.validator['avatar_url']) {
        return this.validator['avatar_url']
      } else {
        return "https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png"
      }
    },

    row_index() {
      return 'row-' + this.idx
    },

    shorten_key(key) {
      return key.substring(0, 6) + "..." + key.substring(key.length - 4)
    },

    is_validator_lido() {
      return this.validator['name']?.substring(0, 4) === 'Lido'
    },

    is_validator_private() {
      return this.validator['commission'] === 100 && this.validator['network'] === 'mainnet'
    },

    shortened_validator_name(name) {
      return (name === this.validator['account'] ? this.shorten_key(name) : name)
    },

    displayed_validator_name() {
      if (this.is_validator_private() && !this.is_validator_lido()) {
        return 'Private Validator'
      } else {
        if (this.validator["name"]) {
          return this.shortened_validator_name(this.validator["name"])
        } else {
          return this.shorten_key(this.validator['account'])
        }
      }
    },

    validator_url() {
      return "/validators/" + this.validator["account"] + "?network=" + this.validator["network"]
    },

    lamports_to_sol(lamports) {
      return lamports / 1000000000
    },

    skipped_vote_percent() {
      if (this.validator['skipped_vote_history'] && this.batch['best_skipped_vote']) {
        var skipped_votes_percent = this.validator['skipped_vote_history'][-1]

        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).round(2) : null
      } else {
        return null
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
      var i = this.idx;
      var target = target+'-'+i;
      var row = document.getElementById('row-'+i);

      // Show selected chart, hide the rest
      var charts = row.getElementsByClassName("column-chart");
      Array.prototype.forEach.call(charts, chart => {
          chart.classList.add('d-none');
      })
      document.getElementById(target).classList.remove('d-none');

      // Set active link
      var ls = row.getElementsByClassName("chart-link");
      Array.prototype.forEach.call(ls, l => {
          l.classList.remove('active')
      });
      event.target.classList.add('active');
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
          <div class="column-info-avatar no-watchlist">
            <div class="img-circle-medium-private" v-if="is_validator_private()">
              <span class="fa-solid fa-users-slash" title="Private Validator"></span>
            </div>
            <img :src="create_avatar_link()" class='img-circle-medium' v-if="!is_validator_private()"/>
          </div>
          
          <div class="column-info-name">
            <a :href="validator_url()" class="fw-bold">
              {{ displayed_validator_name() }}
            </a>
            <small class="ms-1 text-muted">
              (<span class="d-inline-block d-lg-none">Commission:&nbsp;</span>{{ validator["commission"] }}%)
            </small>
            <br />
            <span class="d-inline-block d-lg-none">Scores:&nbsp;</span>
            <validator-scores :score="validator" :account="validator['account']"></validator-scores>

            <div class="d-sm-inline-block small mt-2 mt-sm-0">
              <span class="d-inline-block d-lg-none">Active Stake:&nbsp;</span>
              <span class="me-3">
                {{ lamports_to_sol(validator['active_stake']).toLocaleString('en-US', { maximumFractionDigits: 0 }) }}&nbsp;SOL
              </span>
            </div>
            <div class="d-sm-inline-block small">
              <span class="d-inline-block d-lg-none">Software Version:&nbsp;</span>
              <span class="d-none d-lg-inline-block">V:&nbsp;</span>
              {{ validator['software_version'] }}
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

      <skipped-vote-speedometer :validator="validator" :idx="idx" :batch="batch" />

      <!-- Charts menu -->
      <td class="d-lg-none pt-0">
        <div class="row mb-3">
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
        </div>
      </td>

      <root-distance-chart :validator="validator" :idx="idx" />

      <vote-distance-chart :validator="validator" :idx="idx" />

      <skipped-slots-chart :validator="validator" :idx="idx" />

    </tr>
  `
})

export default ValidatorRow
