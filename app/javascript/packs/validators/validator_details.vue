<template>
  <div>
    <section class="page-header">
      <div class='page-header-name'>
          <div class="img-circle-private img-circle-medium" v-if="is_private(validator)">
            <span class='fas fa-users-slash' title="Private Validator"></span>
          </div>
          <img :src="validator.avatar_url" class="img-circle-medium" v-else-if="validator.avatar_url" >
          <img src="https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png" class="img-circle-medium" v-else >
        <h1 class="word-break">{{ name_or_account(validator) }}</h1>
      </div>

      <div class="d-flex justify-content-between flex-wrap gap-3">
        <div class="d-flex flex-wrap gap-3" v-if="display_staking_info(validator)">
          <a :href="solstake_url(validator)" 
            title="Delegate SOL to this validator on SolStake.io"
            class="btn btn-sm btn-secondary"
            target="_blank">Delegate on Solstake.io</a>
          <a :href="kiwi_url(validator)"
            title="Delegate SOL to this validator on Staking.kiwi"
            class="btn btn-sm btn-secondary"
            target="_blank">Delegate on Staking.kiwi</a>
          <a :href="blazestake_url(validator)"
            title="Delegate SOL to this validator on BlazeStake"
            class="btn btn-sm btn-secondary"
            target="_blank">Liquid Stake through BlazeStake</a>
        </div>

        <div>
          <div class="btn btn-sm btn-danger me-2" title="Validator has 100% commission." v-if="is_private(validator)">private</div>
          <div class="btn btn-sm btn-danger me-2" title="Validator is delinquent." v-if="is_delinquent(validator)">delinquent</div>
          <div class="btn btn-sm btn-danger me-2" title="Validator is inactive." v-if="!is_active()">inactive</div>

          <a href="/faq#admin-warning" :title="validator.admin_warning" v-if="validator.admin_warning">
            <div class="btn btn-sm btn-danger me-2">admin warning</div>
          </a>
          <a href="/faq#withdraw-authority-warning"
            v-if="score.authorized_withdrawer_score == -2"
            title="Withdrawer matches validator identity.">
            <div class="btn btn-sm btn-warning me-2">withdrawer authority</div>
          </a>
          <a href="/faq#score"
            v-if="score.consensus_mods_score == -2"
            title="Validator appears to use unproven software modifications.">
            <div class="btn btn-sm btn-warning me-2">mods</div>
          </a>
        </div>
      </div>
    </section>


    <div class="row">
      <div class="col-lg-6 mb-4">
        <div class="card h-100">
          <div class="card-content pb-0">
            <h2 class="h4 card-heading">Validator Details</h2>
          </div>

          <table class='table table-block-sm mb-0'>
            <tbody>
              <tr>
                <td class="column-lg"><strong>Name:</strong></td>
                <td>
                  {{ validator.name }}
                </td>
              </tr>

              <tr>
                <td><strong>Details:</strong></td>
                <td class="text-break">{{ validator.details }}</td>
              </tr>

              <tr>
                <td><strong>Identity:</strong></td>
                <td><small class="word-break">{{ validator.account }}</small></td>
              </tr>

              <tr>
                <td><strong>Software:</strong></td>
                <td>
                  {{ score.software_version }}
                </td>
              </tr>

              <tr>
                <td><strong>IP:</strong></td>
                <td>{{ score.ip_address }}</td>
              </tr>

              <tr>
                <td><strong>Data Center:</strong></td>
                <td>
                  <a :href="data_center_link(validator)" v-if="validator.dch_data_center_key">
                    {{ validator.dch_data_center_key}}
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="col-lg-6 mb-4">
        <div class="card h-100">
          <div class="card-content pb-0">
            <h2 class="h4 card-heading">Validator Details</h2>
          </div>
          <table class='table table-block-sm mb-0'>
            <tbody>
            <tr>
              <td class="column-lg"><strong>Keybase:</strong></td>
              <td>{{ validator.keybase_id }}</td>
            </tr>

            <tr>
              <td><strong>Website:</strong></td>
              <td><a :href="validator.www_url">{{ validator.www_url }}</a></td>
            </tr>

            <tr>
              <td>
                <strong>Vote Account:</strong>
              </td>
              <td>
                <small class="word-break">
                  <a href="vote_account_path(validator)" v-if="validator.vote_account_active">
                    {{ validator.vote_account_active.account }}
                  </a>
                </small>
              </td>
            </tr>

            <tr>
              <td><strong>Active Stake:</strong></td>
              <td>
                {{ active_stake }} SOL
              </td>
            </tr>

            <tr>
              <td><strong>Commission:</strong></td>
              <td :class="commission_class" data-turbolinks="false">
                {{ score.commission }}&percnt;
                <a :href="commission_histories_path(validator)" class="small" v-if="validator.commission_history_present">
                  (See commission changes)
                </a>
              </td>
            </tr>

            <tr v-if="validator.security_report_url">
              <td>
                <strong>Security Info:</strong>
              </td>
              <td>
                <a href="validator.security_report_url" target="_blank">
                  validator.security_report_url
                </a>
              </td>
            </tr>
              <tr>
                <td>
                  <strong>Scores:</strong>
                </td>
                <td>
                  <validator-scores :score="score"></validator-scores>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-9 col-lg-10">
        <a :href="go_back_link"
           class="btn btn-sm btn-secondary mb-3">
           Back to All Validators
        </a>
      </div>
    </div>

    <div class="row">
      <block-history-chart :root_blocks="root_blocks" v-if="root_blocks.length > 0"></block-history-chart>
      <vote-history-chart :vote_blocks="vote_blocks" v-if="vote_blocks.length > 0"></vote-history-chart>
      <skipped-slots-chart :skipped_slots="skipped_slots" v-if="skipped_slots[1]"></skipped-slots-chart>
    </div>
    <a :href="go_back_link"
        class="btn btn-sm btn-secondary mb-4">
        Back to All Validators
    </a>
    <block-history-table :block_histories="block_histories" :block_history_stats="block_history_stats"></block-history-table>
    <a :href="go_back_link"
        class="btn btn-sm btn-secondary">
        Back to All Validators
    </a>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import scores from './components/scores'
  import blockHistoryChart from './components/block_history_chart'
  import voteHistoryChart from './components/vote_history_chart'
  import skippedSlotsChart from './components/skipped_slots_chart'
  import blockHistoryTable from './components/block_history_table'
  import axios from 'axios';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    props: {
      account: {
        type: String,
        required: true
      }
    },
    data() {
      return {
        validator: {},
        score: {},
        root_blocks: [],
        vote_blocks: [],
        block_histories: [],
        block_history_stats: [],
        skipped_slots: {},
        refresh: null,
        order: null,
        page: null,
        validator_history: {}
      }
    },
    created() {
      let ctx = this
      axios.get("/validators/" + this.account + ".json?network=" + this.network).then(function (response) {
        ctx.validator = JSON.parse(response.data.validator)
        ctx.score = JSON.parse(response.data.score)
        ctx.root_blocks = response.data.root_blocks
        ctx.vote_blocks = response.data.vote_blocks
        ctx.block_histories = response.data.block_histories
        ctx.block_history_stats = response.data.block_history_stats
        ctx.skipped_slots = JSON.parse(response.data.skipped_slots)
        ctx.validator_history = response.data.validator_history
      })

      let uri = window.location.search.substring(1); 
      let params = new URLSearchParams(uri);
      this.refresh = params.get("refresh") == 'true'
      this.order = params.get("order")
      this.page = params.get("page")
    },
    mounted: function(){

    },
    computed: {
      active_stake(){
        return this.validator_history?.active_stake ? this.lamports_to_sol(this.validator_history.active_stake).toLocaleString('en-US', {maximumFractionDigits: 0}) : "N/A";
      },
      go_back_link(){
        return '/validators?network=' + this.validator.network + '&order=' + this.order + '&page=' + this.page
      },
      ...mapGetters([
        'network'
      ])
    },
    methods: {
      lamports_to_sol(lamports) {
        return lamports * 0.000000001;
      },
      is_private(){
        return this.score.commission == 100
      },
      is_delinquent(validator){
        return this.score.delinquent
      },
      is_active(){
        return this.validator.is_active
      },
      name_or_account(validator){
        return validator.name ? validator.name : validator.account
      },
      display_staking_info(validator) {
        return !this.is_private() && validator.is_active && this.validator.vote_account_active
      },
      commission_class() {
        if(this.validator.network == 'mainnet' && this.validator.commission == 100) {
          return 'text-danger'
        }
      },
      commission_histories_path(validator) {
        return '/commission-changes/' + validator.id + '?network=' + validator.network
      },
      data_center_link(validator) {
        return '/data-centers/' + validator.dch_data_center_key + '?network=' + validator.network
      },
      vote_account_path(validator) {
        if (validator.vote_account_active) {
          return "/validators/" + validator.account + "/vote_accounts/" + validator.vote_account_active.account + "?network="
        } else {
          return null
        }
      },
      solstake_url(validator) {
        return "https://solstake.io/#/app/validator/" + validator.vote_account_active.account
      },
      kiwi_url(validator) {
        return "https://staking.kiwi/app/" + validator.vote_account_active.account
      },
      blazestake_url(validator) {
        return "https://stake.solblaze.org/app/?validator=" + validator.vote_account_active.account
      }
    },
    components: {
      "validator-scores": scores,
      "block-history-chart": blockHistoryChart,
      "vote-history-chart": voteHistoryChart,
      "skipped-slots-chart": skippedSlotsChart,
      "block-history-table": blockHistoryTable
    }
  }
</script>
