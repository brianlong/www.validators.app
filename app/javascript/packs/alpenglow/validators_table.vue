<template>
  <div class="card mb-4">
    <div class="table-responsive">
      <table class="table mb-0">
        <thead>
          <tr>
            <th>Validator</th>
            <th class="text-end" v-for="column in columns" :key="column.key">
              <a href="#" @click.prevent="sort(column.key)" :title="column.title">
                {{ column.label }}
                <i v-if="sort_by === column.key"
                   :class="['fa-solid', direction === 'desc' ? 'fa-down-long' : 'fa-up-long', 'text-purple', 'ms-1']"
                   aria-hidden="true"></i>
              </a>
            </th>
            <th>Client</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading && validators.length === 0">
            <td :colspan="columns.length + 2"><small class="text-muted">loading...</small></td>
          </tr>
          <tr v-if="!loading && validators.length === 0">
            <td :colspan="columns.length + 2" class="text-muted">No validator statistics for this epoch yet.</td>
          </tr>
          <tr v-for="validator in validators" :key="validator.vote_account">
            <td>
              <a :href="validator_url(validator)">{{ validator.validator_name || shorten(validator.vote_account) }}</a>
              <div class="small text-muted" v-if="validator.rank !== null">rank {{ validator.rank }}</div>
            </td>
            <td class="text-end">{{ format_stake(validator.stake) }}</td>
            <td class="text-end">
              {{ format_percent(validator.notar_participation) }}
              <div class="small text-muted" v-if="validator.notar_reward_slots">
                {{ validator.notar_votes }} / {{ validator.notar_reward_slots }}
              </div>
            </td>
            <td class="text-end">{{ format_percent(validator.fast_inclusion) }}</td>
            <td class="text-end">{{ format_percent(validator.slow_inclusion) }}</td>
            <td class="text-end">
              {{ validator.divergent_skip_votes }}
              <div class="small text-muted">of {{ validator.skip_votes }} skips</div>
            </td>
            <td class="text-end">{{ validator.leader_slots }}</td>
            <td class="text-end">{{ format_percent(validator.leader_fast_percent) }}</td>
            <td class="text-end">{{ format_decimal(validator.average_final_lag) }}</td>
            <td class="small">
              {{ validator.client || 'N/A' }}
              <div class="text-muted" v-if="validator.version">{{ validator.version }}</div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="card-footer" v-if="total_count > per">
      <b-pagination v-model="page" :total-rows="total_count" :per-page="per" first-text="« First" last-text="Last »" />
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import axios from 'axios'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: {
      epoch: { type: Number, default: null },
      refreshed_at: { type: Number, default: null }
    },

    data() {
      return {
        loading: true,
        validators: [],
        total_count: 0,
        page: 1,
        per: 25,
        sort_by: 'notar_participation',
        direction: 'desc',
        columns: [
          { key: 'stake', label: 'Stake', title: 'Stake used for this epoch (SOL)' },
          { key: 'notar_participation', label: 'Notar Votes', title: 'Share of notar reward certificates signed by the validator' },
          { key: 'fast_inclusion', label: 'Fast Cert', title: 'Share of fast finalization certificates including the validator' },
          { key: 'slow_inclusion', label: 'Slow Cert', title: 'Share of slow finalization certificates including the validator' },
          { key: 'divergent_skip_votes', label: 'Divergent Skips', title: 'Skip votes for slots notarized by the cluster' },
          { key: 'leader_slots', label: 'Blocks', title: 'Blocks produced as leader' },
          { key: 'leader_fast_percent', label: 'Fast Blocks', title: 'Share of own blocks finalized on the fast path' },
          { key: 'average_final_lag', label: 'Final Lag', title: 'Average finalization lag of own blocks (slots)' }
        ]
      }
    },

    computed: {
      ...mapGetters([
        'network'
      ]),

      api_url() {
        let url = '/api/v1/alpenglow-validator-stats/' + this.network +
          '?sort_by=' + this.sort_by + '&direction=' + this.direction + '&page=' + this.page + '&per=' + this.per
        if (this.epoch) {
          url += '&epoch=' + this.epoch
        }
        return url
      }
    },

    watch: {
      epoch() {
        this.reset_page_and_reload()
      },
      refreshed_at() {
        this.get_validators()
      },
      page() {
        this.get_validators()
      }
    },

    mounted() {
      this.get_validators()
    },

    methods: {
      get_validators() {
        var ctx = this
        ctx.loading = true
        return axios.get(ctx.api_url)
          .then(function (response) {
            ctx.validators = response.data.validators
            ctx.total_count = response.data.total_count
          })
          .finally(function () {
            ctx.loading = false
          })
      },

      sort(key) {
        if (this.sort_by === key) {
          this.direction = this.direction === 'desc' ? 'asc' : 'desc'
        } else {
          this.sort_by = key
          this.direction = 'desc'
        }
        this.reset_page_and_reload()
      },

      reset_page_and_reload() {
        if (this.page === 1) {
          this.get_validators()
        } else {
          this.page = 1
        }
      },

      validator_url(validator) {
        return '/validators/' + validator.validator_account + '?network=' + this.network
      },

      shorten(account) {
        return account ? account.substring(0, 6) + '…' + account.substring(account.length - 4) : 'N/A'
      },

      format_stake(lamports) {
        if (lamports === null || lamports === undefined) return 'N/A'
        return Math.round(lamports / 1000000000).toLocaleString('en-US')
      },

      format_percent(value) {
        return value === null || value === undefined ? 'N/A' : value.toFixed(1) + '%'
      },

      format_decimal(value) {
        return value === null || value === undefined ? 'N/A' : value.toFixed(2)
      }
    }
  }
</script>
