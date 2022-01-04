import Vue from 'vue/dist/vue.esm'

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
      console.log(this.validator['skipped_vote_history'] + '/' + this.batch['best_skipped_vote'])
      if (this.validator['skipped_vote_history'] && this.batch['best_skipped_vote']){
        var skipped_votes_percent = this.validator['skipped_vote_history'][-1]
        
        return skipped_votes_percent ? ((batch['best_skipped_vote'] - skipped_votes_percent) * 100.0).round(2) : null
      } else {
        return null
      }
    }
  },
  mounted: function () {
    var speedometer = document.getElementById("spark_line_skipped_vote_" + this.validator['account']).getContext('2d');
    var chart = new Chart(speedometer, {
        type: 'gauge',
        data: {
            datasets: [{
                data: [this.batch['skipped_vote_all_median'] * 2, this.batch['skipped_vote_all_median'], 0.05],
                value: Math.max.apply(Math, [this.skipped_vote_percent(), this.batch['skipped_vote_all_median'] * 3]),
                minValue: this.batch['skipped_vote_all_median'] * 3,
                maxValue: 0.05,
                backgroundColor: [
                  'rgba(202, 202, 202, 0.45)',
                  'rgba(0, 145, 242, 0.4)',
                  'rgba(0, 206, 153, 0.55)'
                ],
                borderColor: ['#cacaca', '#0091f2', '#00ce99'],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            title: {
                display: false
            },
            layout: {
                padding: {
                    left: 0,
                    right: 0
                }
            },
            needle: {
                radiusPercentage: 0,
                widthPercentage: 5,
                lengthPercentage: 80,
                color: '#979797'
            },
            valueLabel: {
                display: false
            }
        }
    });
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

      <td class="column-sm align-middle">
        <div v-if="skipped_vote_percent">
          <div class="d-none d-lg-block">
            <canvas :id=" 'spark_line_skipped_vote_' + validator['account'] "></canvas>
            <div class="text-center text-muted small mt-2">
              {{ skipped_vote_percent() }}
            </div>
          </div>
        </div>
      </td>

    </tr>
  `
})