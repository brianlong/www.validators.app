import Vue from 'vue/dist/vue.esm'
import axios from 'axios'


var StakeAccountRow = Vue.component('StakeAccountRow', {
  props: {
    stake_accounts: {
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
  data() {
    var stake_accounts_for_val = this.stake_accounts[Object.keys(this.stake_accounts)[0]]
    return {
      validator: null,
      validator_url: "/validators/" + this.val_account + "?network=" + stake_accounts_for_val[0].network,
      stake_accounts_for_val: stake_accounts_for_val,
      val_account: Object.keys(this.stake_accounts)[0]
    }
  },
  created () {
    var ctx = this
    if(this.val_account){
      axios.get('/api/v1/validators/' + this.stake_accounts_for_val[0]["network"] + '/' + this.val_account + '?with_history=true')
      .then(function (response){
        ctx.validator = response.data
      })
    }
  },
  methods: {
    filterByStaker: function(e) {
      this.$emit('filter_by_staker', this.stake_account.staker);
    },
    filterByWithdrawer: function(e) {
      this.$emit('filter_by_withdrawer', this.stake_account.withdrawer);
    }
  },
  template: `
    <tbody>
      <validator-row :validator="validator" :idx="idx" :batch="batch" v-if="validator"/>
      <tr>
        <td colspan="6" class="p-0">
          <table class="table table-block-sm stake-accounts-table">
            <thead class="small">
              <tr>
                <th class="column-lg align-middle">Stake Account & Staker</th>
                <th class="column-lg align-middle">Withdrawer</th>
                <th class="column-sm align-middle">Stake</th>
                <th class="column-xs align-middle text-lg-right">
                  <span title="Account Activation Epoch">Act Epoch</span>
                </th>
              </tr>
            </thead>
            <tbody class="small">
            <tr v-for="stake_account in stake_accounts_for_val" :key="stake_account.id">
              <td class="word-break-lg">
                <strong class="d-inline-block d-lg-none">Stake Account:&nbsp;&nbsp;</strong>{{ stake_account.stake_pubkey }}
                <br />
                <strong class="d-inline-block d-lg-none">Staker:&nbsp;&nbsp;</strong>{{ stake_account.staker }}
                <!--<a href="#" title="Filter by staker" @click.prevent="filterByStaker">{{ stake_account.staker }}</a>-->
              </td>
              <td class="word-break-lg">
                <strong class="d-inline-block d-lg-none">Withdrawer:&nbsp;&nbsp;</strong>{{ stake_account.pool_name }}
                <br />
                {{ stake_account.withdrawer }}
                <!--<a href="#" title="Filter by withdrawer" @click.prevent="filterByWithdrawer">{{ stake_account.withdrawer }}</a>-->
              </td>
              <td>
                <strong class="d-inline-block d-lg-none">Stake:&nbsp;&nbsp;</strong>
                <span v-if="stake_account.active_stake < 500000000">
                  <0.5 SOL
                </span>
                <span v-else>
                  {{ (stake_account.active_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL
                </span>
              </td>
              <td class="text-lg-right">
                <strong class="d-inline-block d-lg-none">Activation Epoch:&nbsp;&nbsp;</strong>{{ stake_account.activation_epoch }}
              </td>
            </tr>
            </tbody>
          </table>
        </td>
      </tr>
    </tbody>
  `
})

export default StakeAccountRow
