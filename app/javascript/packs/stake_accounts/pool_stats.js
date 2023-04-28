import Vue from 'vue/dist/vue.esm'

const DELEGATION_STRATEGY_URLS = {
  "DAOPool": "https://monkedao.medium.com/daosol-the-next-step-in-decentralizing-solana-7519e3b2bded",
  "Jpool": "https://docs.jpool.one/technical-stuff/staking-strategy",
  "Marinade": "https://docs.marinade.finance/marinade-protocol/validators",
  "Lido": "https://solana.foundation/stake-pools",
  "Socean": "https://docs.socean.fi/faq#how-does-socean-delegate-my-funds",
  "Eversol": "https://docs.eversol.one/litepaper/delegation-strategy",
  "BlazeStake": "https://stake-docs.solblaze.org/protocol/delegation-strategy",
  "Jito": "https://jito-foundation.gitbook.io/jitosol/jitosol-liquid-staking/stake-delegation"
}

var StakePoolStats = Vue.component('StakePoolStats', {
  props: {
    pool: {
      type: Object,
      required: true
    }
  },

  data() {
    return {}
  },

  methods: {
    delegation_strategy_url() {
      return DELEGATION_STRATEGY_URLS[this.pool.name]
    }
  },

  template: `
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h4 card-heading mb-2">
          {{ pool.name }} {{ pool.ticker ? '(' + pool.ticker + ')' : '' }} Statistics
        </h2>
        <div class="text-center text-muted small mb-4 pb-2">
          <a v-bind:href="delegation_strategy_url()" target="_blank">See delegation strategy</a>
        </div>

        <div class="row ps-lg-4 ps-xl-5">
          <div class="col-md-4 ps-lg-4 ps-xl-5">
            <div class="mb-2">
              <span class="stat-title-3">
                <i class="fa-solid fa-code-branch text-success me-2"></i>Nodes&nbsp;
              </span>
            </div>
            <div>
              <span class="text-muted">
                Total&nbsp;<small>(> 1 SOL)</small>:&nbsp;
              </span>
              <strong class="text-success">{{ pool.validators_count }}</strong>
            </div>
            <div class="mb-4">
              <span class="text-muted">
                Delinquent&nbsp;<small>(> 1 SOL)</small>:&nbsp;
              </span>
              <strong class="text-success">{{ pool.delinquent_count }}</strong>
            </div>

            <div class="mb-3">
              <div class="stat-title-3 mb-2">
                <i class="fa-solid fa-dollar-sign text-purple me-1"></i>Stake
              </div>
              <div>
                <span class="text-muted">Total:&nbsp;</span>
                <strong class="text-purple">{{ (pool.total_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL</strong>
              </div>
              <div>
                <span class="text-muted">Avg Stake:&nbsp;</span>
                <strong class="text-purple">{{ (pool.average_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL</strong>
              </div>
            </div>
          </div>

          <div class="col-md-4 ps-lg-4 ps-xl-5">
            <div class="stat-title-3 mb-2">
              <i class="fa-solid fa-hand-holding-dollar text-success me-2"></i>Fees
            </div>
            <div>
              <span class="text-muted">Manager Fee:&nbsp;</span>
              <strong class="text-success">{{ pool.manager_fee ? pool.manager_fee + '%' : '0%' }}</strong>
            </div>
            <div>
              <span class="text-muted">Deposit Fee:&nbsp;</span>
              <strong class="text-success">{{ pool.deposit_fee ? pool.deposit_fee + '%' : 0 }}</strong>
            </div>
            <div>
              <span class="text-muted">Withdrawal Fee:&nbsp;</span>
              <strong class="text-success">{{ pool.withdrawal_fee ? pool.withdrawal_fee + '%' : 0 }}</strong>
            </div>
            <div class="mb-4">
              <span class="text-muted">Avg Validators Fee:&nbsp;</span>
              <strong class="text-success">{{ pool.average_validators_commission ? pool.average_validators_commission.toFixed(2) : 0 }}%</strong>
            </div>

            <div class="mb-3">
              <span class="stat-title-3">
                <i class="fa-solid fa-chart-line text-purple me-2"></i>ROD:&nbsp;
              </span>
              <strong class="text-purple">{{ pool.average_apy ? pool.average_apy.toFixed(2) + '%' : 'N / A' }}</strong>
            </div>
          </div>

          <div class="col-md-4">
            <div class="mb-2">
              <span class="stat-title-3">
                <i class="fa-solid fa-trophy text-success me-2"></i>Performance
              </span>
            </div>
            <div>
              <span class="text-muted">Avg Skipped Slots:&nbsp;</span>
              <strong class="text-success">{{ pool.average_skipped_slots ? pool.average_skipped_slots.toFixed(2) : 0 }}&percnt;</strong>
            </div>
            <div>
              <span class="text-muted">Avg Lifetime:&nbsp;</span>
              <strong class="text-success">{{ pool.average_lifetime ? pool.average_lifetime + ' days' : 0 }}</strong>
            </div>
            <div>
              <span class="text-muted">Avg Uptime:&nbsp;</span>
              <strong class="text-success">{{ pool.average_uptime ? pool.average_uptime.toFixed(1) + ' days': 0 }}</strong>
            </div>
            <div class="">
              <span class="text-muted">Avg Score:&nbsp;</span>
              <strong class="text-success">{{ pool.average_score || 'N / A' }}</strong>
            </div>
          </div>
        </div>
      </div>
    </div>
  `
})

export default StakePoolStats
