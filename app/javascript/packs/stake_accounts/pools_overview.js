import Vue from 'vue/dist/vue.esm'

var StakePoolsOverview = Vue.component('StakePoolsOverview', {
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
    }
  },
  template: `
    <div class="card h-100">
      <div class="card-content">
        <h3 class="card-heading mb-2">
          Stake Pools overview
        </h3>
        <div class="text-center text-muted small mb-4">
          <a href="#" @click.prevent="go_to_metrics()">See metrics explanation</a>
        </div>
      </div>

      <table class="table table-block-sm" id="validators-table">
        <thead>
        <tr>
          <th class="align-middle">Stake Pool</th>
          <th class="align-middle">
            Nodes<br />
            <small class="text-muted">(delinquent)</small>
          </th>
          <th class="align-middle">
            Stake<br />
            <small class="text-muted">average</small>
          </th>
          <th class="align-middle">TBA</th>
          <th class="align-middle">TBA</th>
          <th class="align-middle">TBA</th>
        </tr>
        </thead>
          
        <tbody>
        <tr v-for="pool in stake_pools">
          <td>{{ pool.name }}</td>
          <td>
            {{ pool.validators_count }}&nbsp;<span class="text-muted">({{ pool.average_delinquent }})</span>
          </td>
          <td>
            {{ (pool.total_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL<br />
            <small class="text-muted">{{ (pool.average_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL</small>
          </td>
          <td>TBA</td>
          <td>TBA</td>
          <td>TBA</td>
        </tr>
        </tbody>
      </table>
    </div>
  `
})

export default StakePoolsOverview
