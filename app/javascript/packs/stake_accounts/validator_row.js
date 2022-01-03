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

      <td class="column-sm align-middle">
        <% skipped_vote_percent = skipped_vote_percent(validator, batch) %>
        <% if skipped_vote_percent %>
          <div class="d-none d-lg-block">
            <%= render 'validators/speedometer_chart',
                       canvas_name: "spark_line_skipped_vote_#{validator.account}",
                       value: [skipped_vote_percent, batch.skipped_vote_all_median.to_f * 3].max,
                       chart_steps: [batch.skipped_vote_all_median.to_f * 2, batch.skipped_vote_all_median.to_f, 0.05],
                       min_value: batch.skipped_vote_all_median.to_f * 3,
                       max_value: 0.05
            %>
            <div class="text-center text-muted small mt-2">
              <%= number_to_percentage(skipped_vote_percent, precision: 2) %>
            </div>
          </div>
        <% else %>
          <span class="d-none d-lg-block text-center text-muted">N/A</span>
        <% end %>
        <span class="d-inline-block d-lg-none">
          Skipped Vote&nbsp;%:
          <%= skipped_vote_percent ? number_to_percentage(skipped_vote_percent, precision: 2) : "N/A" %>
        </span>
      </td>

    </tr>
  `
})