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
    return {

    }
  },
  methods: {

  },
  template: `
    <div class="card">
      <div class="card-content row">
        <div class="col-12">
          <h2 class="float-left"> {{ pool.name }} ({{ pool.ticker }}) statistics </h2>
        </div>

        <div class="col-4">
          <table class="table table-block-sm mb-0" v-if="!is_loading">
            <tbody>
              <tr>
                <td>APY: </td>
                <td></td>
              </tr>
              <tr>
                <td>Manager Fee: </td>
                <td>{{ pool.manager_fee }}%</td>
              </tr>
              <tr>
                <td>Average Commission: </td>
                <td>{{ pool.average_validators_commission.toFixed(2) }}%</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="col-4">
          <table class="table table-block-sm mb-0" v-if="!is_loading">
            <tbody>
              <tr>
                <td>Total Stake: </td>
                <td> {{ (total_stake / 1000000000).toFixed(2) }} </td>
              </tr>
              <tr>
                <td>Number of Validators </td>
                <td></td>
              </tr>
              <tr>
                <td>Average Delinquent: </td>
                <td> {{ pool.average_delinquent }} </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="col-4">
          <table class="table table-block-sm mb-0" v-if="!is_loading">
            <tbody>
              <tr>
                <td>Average Skipped Slots: </td>
                <td> {{ pool.average_skipped_slots.toFixed(2) }} </td>
              </tr>
              <tr>
                <td>Average Lifetime: </td>
                <td> {{ pool.average_lifetime }} </td>
              </tr>
              <tr>
                <td>Average Uptime: </td>
                <td> {{ pool.average_uptime }} </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `
})

export default StakePoolStats
