<template>
  <div>
    <section class="page-header">
      <div class='page-header-name'>
        <div class="img-circle-medium-private" v-if="should_hide_avatar(validator)">
          <span class='fas fa-users-slash' title="Private Validator"></span>
        </div>
        <img :src="avatar_url(validator)" class='img-circle-medium' v-else />

        <h1 class="word-break" v-if="is_loading_validator">loading...</h1>
        <h1 class="word-break" v-else>{{ name_or_account(validator) }}</h1>
      </div>

      <div class="d-flex justify-content-between flex-wrap gap-3">
        <div class="d-flex flex-wrap gap-3" v-if="display_staking_info(validator)">
          <a :href="generate_stake_url(stake[0], validator)"
             :title="stake[1].title"
             class="btn btn-sm btn-secondary"
             target="_blank"
             v-for="stake in shuffle_stake_delegations()"
             v-bind="stake.name">
            {{ stake[1].name }}
          </a>
        </div>

        <div class="d-flex flex-wrap gap-3">
          <div class="btn btn-sm btn-danger" title="Validator has 100% commission." v-if="is_private(validator)">private</div>
          <div class="btn btn-sm btn-danger" title="Validator is delinquent." v-if="is_delinquent()">delinquent</div>
          <div class="btn btn-sm btn-danger" title="Validator is inactive." v-if="!is_active()">inactive</div>

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

          <div class="img-loading" v-if="is_loading_validator">
            <img v-bind:src="loading_image" width="100">
          </div>

          <table class="table table-block-sm mb-0" v-if="!is_loading_validator">
            <tbody>
              <tr>
                <td class="column-lg"><strong>Name:</strong></td>
                <td>
                  {{ validator.name }}
                </td>
              </tr>

              <tr>
                <td><strong>Details:</strong></td>
                <td class="small text-break">{{ validator.details }}</td>
              </tr>

              <tr>
                <td><strong>Identity:</strong></td>
                <td class="small word-break">{{ validator.account }}</td>
              </tr>

              <tr>
                <td><strong>Software:</strong></td>
                <td>
                  {{ score.software_version }}
                  <span v-if="score.software_client">({{ score.software_client }})</span>
                </td>
              </tr>

              <tr>
                <td><strong>IP:</strong></td>
                <td>{{ score.ip_address }}</td>
              </tr>

              <tr>
                <td><strong>Data Center:</strong></td>
                <td data-turbolinks="false">
                  <a :href="data_center_link(validator)" v-if="validator.dch_data_center_key">
                    {{ validator.dch_data_center_key}}
                  </a>
                </td>
              </tr>

              <tr v-if="validator.keybase_id">
                <td class="column-lg"><strong>Keybase:</strong></td>
                <td>{{ validator.keybase_id }}</td>
              </tr>

              <tr>
                <td><strong>Creation Date:</strong></td>
                <td>
                  {{ date_time_with_timezone(validator.created_at) }}
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

          <div class="img-loading" v-if="is_loading_validator">
            <img v-bind:src="loading_image" width="100">
          </div>

          <table class="table table-block-sm mb-0" v-if="!is_loading_validator">
            <tbody>
              <tr>
                <td><strong>Website:</strong></td>
                <td class="small">{{ validator.www_url }}</td>
              </tr>

              <tr>
                <td>
                  <strong>Vote Account:</strong>
                </td>
                <td class="small word-break">
                  <a :href="vote_account_path(validator)" data-turbolinks=false v-if="validator.vote_account_active">
                    {{ validator.vote_account_active.account }}
                  </a>
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
                  <a :href="commission_histories_path(validator)" class="small" v-if="validator.commission_histories_exist">
                    (See commission changes)
                  </a>
                </td>
              </tr>

              <tr v-if="validator.jito">
                <td><strong>Jito Commission:</strong></td>
                <td :class="commission_class" data-turbolinks="false">
                  {{ validator.jito_commission / 100 }}&percnt;
                </td>
              </tr>

              <tr v-if="validator.is_dz || jito_maximum_commission(validator)">
                <td><strong>Associations:</strong></td>
                <td>
                  <img :src="jito_badge" class="img-xxs me-1" title="Jito validator" v-if="jito_maximum_commission(validator)">
                  <img :src="double_zero_badge" class="img-xs" title="DoubleZero validator" v-if="validator.is_dz">
                </td>
              </tr>

              <tr v-if="validator.stake_pools_list.length > 0">
                <td><strong>Stake Pools:</strong></td>
                <td>
                  <span v-for="stake_pool_name in validator.stake_pools_list">
                    <img class="img-xs me-2"
                         :title="stake_pool_name + ' stake pool'"
                         :alt="stake_pool_name"
                         :src="stake_pool_small_logo(stake_pool_name)" />
                  </span>
                </td>
              </tr>

              <tr v-if="validator.security_report_url">
                <td>
                  <strong>Security Info:</strong>
                </td>
                <td class="small word-break">
                  <a :href="validator.security_report_url" target="_blank">
                    {{ validator.security_report_url }}
                  </a>
                </td>
              </tr>

              <tr>
                <td>
                  <strong>Scores:</strong>
                </td>
                <td>
                  <validator-scores :score="score" :account="validator.account"></validator-scores>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="d-flex justify-content-between flex-wrap gap-3 mb-4">
      <div>
        <a :href="go_back_link"
           class="btn btn-sm btn-secondary"
           data-turbolinks="false">
             Back to All Validators
        </a>
      </div>
      <div class="toggle-container pt-1">
        <a href="#" @click.prevent="live = !live"><i class="fa-solid toggle" :class="live ? 'fa-toggle-on' : 'fa-toggle-off'"></i></a>
        <p class="small text-muted toggle-label">REFRESH</p>
      </div>
    </div>

    <div class="img-loading" v-if="is_loading_validator">
      <img v-bind:src="loading_image" width="100">
    </div>

    <div class="row" v-if="!is_loading_validator">
      <block-history-chart :root_blocks="root_blocks" v-if="root_blocks.length > 0"></block-history-chart>
      <vote-history-chart :vote_blocks="vote_blocks" v-if="vote_blocks.length > 0"></vote-history-chart>
      <skipped-slots-chart :skipped_slots="skipped_slots" v-if="skipped_slots[1]"></skipped-slots-chart>
      <skipped-after-chart :skipped_after="skipped_after" v-if="skipped_after[1]"></skipped-after-chart>
      <vote-latency-chart :vote_latencies="vote_latencies" v-if="vote_latencies.length > 0"></vote-latency-chart>
    </div>

    <a :href="go_back_link"
        class="btn btn-sm btn-secondary mb-4"
        data-turbolinks="false">
      Back to All Validators
    </a>

    <div class="img-loading" v-if="is_loading_validator">
      <img v-bind:src="loading_image" width="100">
    </div>

    <block-history-table :block_histories="block_histories"
                         :block_history_stats="block_history_stats"
                          v-if="!is_loading_validator">
    </block-history-table>

    <a :href="go_back_link"
        class="btn btn-sm btn-secondary"
        data-turbolinks="false">
      Back to All Validators
    </a>

    <validator-score-modal :account_prop="validator.account"
                           v-if="!is_loading_validator">
    </validator-score-modal>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import scores from './components/scores'
  import blockHistoryChart from './charts/block_history_chart'
  import voteHistoryChart from './charts/vote_history_chart'
  import skippedSlotsChart from './charts/skipped_slots_large_chart'
  import skippedAfterChart from './charts/skipped_after_large_chart'
  import voteLatencyChart from './charts/vote_latency_chart'
  import blockHistoryTable from './components/block_history_table'
  import validatorScoreModal from "./components/validator_score_modal"
  import axios from 'axios';
  import loadingImage from 'loading.gif'
  import jitoBadge from 'jito.svg'
  import doubleZeroBadge from 'doublezero.svg'
  import '../mixins/numbers_mixins'
  import '../mixins/dates_mixins'
  import '../mixins/stake_pools_mixins'
  import '../mixins/validators_mixins'

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  const STAKE_DELEGATIONS = {
    solstake: {
      title: 'Delegate SOL to this validator on SolStake.io',
      name: 'Delegate on Solstake.io',
      excluded_countries: []
    },
    kiwi: {
      title: 'Delegate SOL to this validator on Staking.kiwi',
      name: 'Delegate on Staking.kiwi',
      excluded_countries: []
    },
    blazestake: {
      title: 'Delegate SOL to this validator on BlazeStake',
      name: 'Liquid Stake through BlazeStake',
      excluded_countries: ['GB']
    }
  }

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
        skipped_after: {},
        live: false,
        order: null,
        page: null,
        geo_country: null,
        validator_history: {},
        loading_image: loadingImage,
        jito_badge: jitoBadge,
        double_zero_badge: doubleZeroBadge,
        is_loading_validator: true,
        validator_score_details_attrs: {},
        vote_latencies: {},
        reload_time: 1000 * 60 * 3 // 3 minutes
      }
    },

    created() {
      this.get_validator_data()
      let uri = window.location.search.substring(1)
      let params = new URLSearchParams(uri)
      this.order = params.get("order")
      this.page = params.get("page")
      this.reload_validator_data()
    },

    computed: {
      active_stake() {
        return this.validator_history?.active_stake ? this.lamports_to_sol(this.validator_history.active_stake).toLocaleString('en-US', {maximumFractionDigits: 0}) : "N/A";
      },

      go_back_link() {
        return '/validators?network=' + this.validator.network + '&order=' + this.order + '&page=' + this.page
      },
      ...mapGetters([
        'network'
      ])
    },

    methods: {
      get_validator_data(){
        let ctx = this
        axios.get("/api/v1/validators/" + this.network + "/" + this.account + "?internal=true").then(function (response) {
          ctx.validator = JSON.parse(response.data.validator)
          ctx.validator_score_details_attrs = JSON.parse(response.data.validator_score_details)
          ctx.score = JSON.parse(response.data.score)
          ctx.root_blocks = response.data.root_blocks
          ctx.vote_blocks = response.data.vote_blocks
          ctx.skipped_after = JSON.parse(response.data.skipped_after)
          ctx.block_histories = response.data.block_histories
          ctx.block_history_stats = response.data.block_history_stats
          ctx.skipped_slots = JSON.parse(response.data.skipped_slots)
          ctx.validator_history = response.data.validator_history
          ctx.geo_country = response.data.geo_country
          ctx.vote_latencies = JSON.parse(response.data.vote_latencies)
          ctx.is_loading_validator = false
        })
      },

      reload_validator_data() {
        setTimeout( () => {
          if(this.live) {
            this.get_validator_data()
          }
          this.reload_validator_data()
        }, this.reload_time)
      },

      is_private() {
        return this.score.commission == 100
      },

      should_hide_avatar(validator) {
        return this.is_private(validator) && validator.network == 'mainnet'
      },

      is_delinquent() {
        return this.score.delinquent
      },

      is_active() {
        return this.validator.is_active || true
      },

      name_or_account(validator) {
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
        let key = validator.dch_data_center_key.replace('/', '-slash-')
        return '/data-centers/' + key + '?network=' + validator.network
      },

      vote_account_path(validator) {
        if (validator.vote_account_active) {
          return "/validators/" + validator.account + "/vote_accounts/" + validator.vote_account_active.account + "?network=" + validator.network
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
      },

      marinade_url(validator) {
        return "https://marinade.finance/app/staking/?stakeTo=" + validator.vote_account_active.account
      },

      generate_stake_url(stake, validator) {
        return this[stake + '_url'](validator)
      },

      shuffle_stake_delegations() {
        let delegations = {}
        if(this.geo_country == null) {
          delegations = Object.entries(STAKE_DELEGATIONS)
        } else {
          delegations = Object.entries(STAKE_DELEGATIONS).filter(
            stake => !stake[1].excluded_countries.includes(this.geo_country)
          )
        }
        return delegations.map(stake => [stake[0], stake[1]])
                          .sort((a, b) => 0.5 - Math.random())
      }
    },

    components: {
      "validator-scores": scores,
      "block-history-chart": blockHistoryChart,
      "vote-history-chart": voteHistoryChart,
      "skipped-slots-chart": skippedSlotsChart,
      "block-history-table": blockHistoryTable,
      "validator-score-modal": validatorScoreModal,
      "skipped-after-chart": skippedAfterChart,
      "vote-latency-chart": voteLatencyChart
    }
  }
</script>
