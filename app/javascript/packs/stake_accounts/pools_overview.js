import Vue from '../shared/vue_setup'

const StakePoolsOverview = {
  name: 'StakePoolsOverview',
  props: {
    stake_pools: {
      type: Array,
      required: true
    }
  },

  data() {
    return {}
  },

  methods: {
    go_to_metrics() {
      document.getElementById("metrics").scrollIntoView()
    },
    filterByWithdrawer: function(pool) {
      this.$emit('filter_by_withdrawer', pool);
    }
  },

  template: `
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h4 card-heading mb-2">Stake Pools Overview</h2>
        <div class="text-center text-muted small">
          <a href="#" @click.prevent="go_to_metrics()">See metrics explanation</a>
        </div>
      </div>

      <div class="table-responsive-lg">
        <table class="table mb-0">
          <thead>
          <tr>
            <th class="column-sm">Stake Pool</th>
            <th class="column-sm">
              Nodes <small class="text-nowrap">> 1 SOL</small><br />
              <small class="text-muted">(Delinquent)</small>
            </th>
            <th class="column-md">
              Total Stake<br />
              <small class="text-muted">Average</small>
            </th>
            <th class="column-md">
              Manager Fee<br />
              <small class="text-muted">Avg Validators Fee</small>
            </th>
            <th class="column-sm">ROD</th>
            <th class="column-md">
              Avg Score<br />
              <small class="text-muted">Maximum: 13</small>
            </th>
          </tr>
          </thead>

          <tbody>
          <tr v-for="pool in stake_pools">
            <td>
              <a href="#"
                 title="Show more details about stake pool"
                 @click.prevent="filterByWithdrawer(pool)">
                {{ pool.name }}
              </a>
            </td>
            <td>
              {{ pool.validators_count }}&nbsp;<span class="text-muted">({{ pool.delinquent_count }})</span>
            </td>
            <td>
              {{ (pool.total_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL<br />
              <small class="text-muted">{{ (pool.average_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL</small>
            </td>
            <td>
              {{ pool.manager_fee ? pool.manager_fee + '%' : '0%' }}<br />
              <small class="text-muted">{{ pool.average_validators_commission ? pool.average_validators_commission.toFixed(2) : 0 }}%</small>
            </td>
            <td>
              {{ pool.average_apy ? pool.average_apy.toFixed(2) + '%' : 'N / A' }}
            </td>
            <td>
              {{ pool.average_score || 'N / A' }}
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
}

export default StakePoolsOverview
