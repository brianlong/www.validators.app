import Vue from 'vue/dist/vue.esm'
import rootDistanceChart from './charts/root_distance_chart'
import voteDistanceChart from './charts/vote_distance_chart'
import skippedSlotsChart from './charts/skipped_slot_chart'
import skippedVoteSpeedometer from './charts/skipped_vote_speedometer'

var chart_green = '#00ce99'
var chart_blue = '#0091f2'
var chart_lightgrey = '#cacaca'
var chart_green_t = 'rgba(0, 206, 153, 0.4)'
var chart_blue_t = 'rgba(0, 145, 242, 0.25)'
var chart_lightgrey_t = 'rgba(202, 202, 202, 0.3)'

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
    'skipped-vote-speedometer': skippedVoteSpeedometer
  },
  methods: {
    create_avatar_link() {
      if(this.validator['avatar_url']){
        return this.validator['avatar_url']
      } else {
        return "https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png"
      }
    },
    row_index() {
      return 'row-' + this.idx
    },
    validator_name() {
      if(this.validator["name"]){
        return this.validator["name"]
      } else {
        return this.validator["account"].substring(0,5) + "..." +  this.validator["account"].substring(this.validator["account"].length - 5)
      }
    },
    validator_url() {
      return "/validators/" + this.validator["account"] + "?network=" + this.validator["network"]
    },
    lamports_to_sol(lamports) {
      return lamports / 1000000000
    },
    skipped_vote_percent() {
      if (this.validator['skipped_vote_history'] && this.batch['best_skipped_vote']){
        var skipped_votes_percent = this.validator['skipped_vote_history'][-1]
        
        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).round(2) : null
      } else {
        return null
      }
    },
    chart_line_color(val) {
      if (val == 2) {
        return chart_green
      } else if(val == 1) {
        return chart_blue
      }
      return chart_lightgrey
    },
    chart_fill_color(val) {
      if (val == 2) {
        return chart_green_t
      } else if(val == 1) {
        return chart_blue_t
      }
      return chart_lightgrey_t
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
  template: `
    <tr :id="row_index()">
      <td class="column-avatar d-none d-xl-table-cell align-middle">
        <div class="avatar">
          <img :src="create_avatar_link()" class='img-circle-medium'/>
        </div>
      </td>

      <td class="column-info align-middle">
        <a :href="validator_url" class="font-weight-bold">
          <span>{{idx}}.&nbsp;</span> {{ validator_name() }}
        </a>
        <small>
          (<span class="d-inline-block d-lg-none">Commission:&nbsp;</span>{{ validator["commission"] }}%)
        </small>
        <a v-if="validator['authorized_withdrawer_score']== -2" href="/faq#withdraw-authority-warning" title="Withdrawer matches validator identity.">
          <i class="fas fa-exclamation-triangle text-warning ml-1"></i>
        </a>
        <br />
        <span class="d-inline-block d-lg-none">Active Stake:&nbsp;</span>
        <small>
          {{ lamports_to_sol(validator['active_stake']).toLocaleString() }}
          ( {{ validator['stake_concentration'] * 100.0 }}% )
        </small>
        <br />
        <span class="d-inline-block d-lg-none">Version:&nbsp;</span>
        <small>
          <span class="d-none d-lg-inline-block">Version:&nbsp;</span>
          {{ validator['software_version'] }}
        </small>
        <br />
        <span class="d-inline-block d-lg-none">Scores:&nbsp;</span>
        <small>
          <i :class=" 'fas fa-circle score-' + validator['root_distance_score'] "
            :title=" 'Root Distance Score = ' + validator['root_distance_score'] "></i>&nbsp;
          <i :class=" 'fas fa-circle score-' + validator['vote_distance_score'] "
            :title=" 'Vote Distance Score = ' + validator['vote_distance_score'] "></i>&nbsp;
          <i :class=" 'fas fa-circle score-' + validator['skipped_slot_score'] "
            :title=" 'Skipped Slot Score = ' + validator['skipped_slot_score'] "></i>&nbsp;
          <i :class=" 'fas fa-circle score-' + validator['published_information_score'] "
            :title=" 'Published Information Score = ' + validator['published_information_score'] "></i>&nbsp;
          <i :class=" 'fas fa-circle score-' + validator['software_version_score'] "
            :title=" 'Software Version Score = ' + validator['software_version_score'] "></i>&nbsp;
          <i :class=" 'fas fa-circle score-' + validator['security_report_score'] "
            :title=" 'Security Report Score = ' + validator['security_report_score'] "></i>&nbsp;
          <i class="fas fa-minus-circle text-warning"
            v-if="validator['authorized_withdrawer_score'] < 0"
            :title=" 'Authorized Withdrawer Score = ' + validator['authorized_withdrawer_score'] "></i>&nbsp;
          <i class="fas fa-minus-circle text-warning"
            v-if="validator['stake_concentration_score'] < 0"
            :title=" 'Stake Concentration Score = ' + validator['stake_concentration_score'] "></i>&nbsp;
          <i class="fas fa-minus-circle text-warning"
            v-if="validator['data_center_concentration_score'] < 0"
            :title=" 'Data Center Concentration Score = ' + validator['data_center_concentration_score'] "></i>&nbsp;
          
          (<span class="d-inline-block d-lg-none">Total:&nbsp;</span>{{ validator['total_score'] }})
        </small>
        <br /><small v-if="validator['delinquent']" class="text-danger">delinquent</small>
      </td>

      <skipped-vote-speedometer :validator="validator" :idx="idx" :batch="batch" />

      <td class="d-lg-none pt-0">
        <div class="row mb-3">
          <div class="col pr-0">
            <a class="chart-link" :data-iterator="idx" data-target="root-distance" href="">
              Root <br class="d-xxs-inline-block" />Distance
            </a>
          </div>
          <div class="col pr-0">
            <a class="chart-link" :data-iterator="idx" data-target="vote-distance" href="">
              Vote <br class="d-xxs-inline-block" />Distance
            </a>
          </div>
          <div class="col">
            <a class="chart-link" :data-iterator="idx" data-target="skipped-slots" href="">
              Skipped <br class="d-xxs-inline-block" />Slots
            </a>
          </div>
        </div>
      </td>

      <root-distance-chart :validator="validator" :idx="idx" :batch="batch" />

      <vote-distance-chart :validator="validator" :idx="idx" :batch="batch" />

      <skipped-slots-chart :validator="validator" :idx="idx" :batch="batch" />

    </tr>
  `
})