import Vue from 'vue/dist/vue.esm'

var StakePoolStats = Vue.component('StakePoolStats', {
  props: {
    pool: {
      type: Object,
      required: true
    },
    total_stake: {
      type: Number,
      required: true
    }
  },
  data() {
    return {}
  },
  methods: {
    go_to_metrics() {
      document.getElementById("metrics").scrollIntoView()
    }
  },
  template: `
    <div class="card h-100">
      <div class="card-content">
        <h3 class="card-heading">
          {{ pool.name }} {{ pool.ticker ? '(' + pool.ticker + ')' : '' }} statistics
        </h3>
        
        <div class="row pl-lg-4 pl-xl-5">
          <div class="col-md-4 pl-lg-4 pl-xl-5">
            <div class="mb-2">
              <span class="stat-title-3">
                <i class="fas fa-code-branch text-success mr-2"></i>Nodes&nbsp;
              </span>
            </div>
            <div>
              <span class="text-muted">Total:&nbsp;</span>
              <strong class="text-success">{{ pool.validators_count }}</strong>
            </div>
            <div class="mb-4">
              <span class="text-muted">Delinquent:&nbsp;</span>
              <strong class="text-success">{{ pool.average_delinquent }}</strong>
            </div>

            <div class="mb-3">
              <span class="stat-title-3">
                <i class="fas fa-dollar-sign text-purple mr-1"></i>
                Stake:&nbsp;
              </span>
              <strong class="text-purple">{{ (total_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL</strong>
            </div>
          </div>
          
          <div class="col-md-4 pl-lg-4 pl-xl-5">
            <div class="stat-title-3 mb-2">
              <i class="fas fa-hand-holding-usd text-success mr-2"></i>Fees
            </div> 
            <div>
              <span class="text-muted">Manager Fee:&nbsp;</span>
              <strong class="text-success">{{ pool.manager_fee ? pool.manager_fee + '%' : 'N / A' }}</strong>
            </div>
            <div class="mb-4">
              <span class="text-muted">Avg Commission:&nbsp;</span>
              <strong class="text-success">{{ pool.average_validators_commission ? pool.average_validators_commission.toFixed(2) : 'N / A' }}%</strong>
            </div>
            <div class="mb-3">
              <span class="stat-title-3">
                <i class="fas fa-chart-line text-purple mr-2"></i>APY:&nbsp;
              </span>
              <strong class="text-purple">{{ pool.average_apy ? pool.average_apy.toFixed(2) + '%' : 'N / A' }}</strong>
            </div>
          </div>

          <div class="col-md-4">
            <div class="mb-2">
              <span class="stat-title-3">
                <i class="fas fa-trophy text-success mr-2"></i>Performance
              </span>
            </div>
            <div>
              <span class="text-muted">Avg Skipped Slots:&nbsp;</span>
              <strong class="text-success">{{ pool.average_skipped_slots ? pool.average_skipped_slots.toFixed(2) : 'N / A' }}&percnt;</strong>
            </div>
            <div>
              <span class="text-muted">Avg Lifetime:&nbsp;</span>
              <strong class="text-success">{{ pool.average_lifetime ? pool.average_lifetime + ' days' : 'N / A' }}</strong>
            </div>
            <div>
              <span class="text-muted">Avg Uptime:&nbsp;</span>
              <strong class="text-success">{{ pool.average_uptime ? pool.average_uptime.toFixed(1) + ' days': 'N / A' }}</strong>
            </div>
            <div class="">
              <span class="text-muted">Avg Score:&nbsp;</span>
              <strong class="text-success">{{ pool.average_score || 'N / A' }}</strong>
            </div>
          </div>
        </div>
        <div class="text-center">
          <small><a href="#" @click.prevent="go_to_metrics()">go to metrics explanation</a><small>
        </div>
      </div>
    </div>
  `
})

export default StakePoolStats
