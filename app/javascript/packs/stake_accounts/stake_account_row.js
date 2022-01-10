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
    <div>
      <div class="table-responsive-lg" v-if="validator">
        <table >
          <tbody>
            <validator-row :validator="validator" :idx="idx" :batch="batch" v-if="validator"/>
          </tbody>
        </table>
      </div>
  
      <div class="table-responsive-lg">
        <table class="table table-block-sm">
          <tbody>
            <tr v-for="stake_account in stake_accounts_for_val" :key="stake_account.id">
              <td>
                {{ (stake_account.active_stake / 1000000000).toLocaleString('en-US') }} SOL
              </td>
              <td class="word-break-md">
                <small>{{ stake_account.stake_pubkey }}</small>
                <br />
                <small><a href="#" @click.prevent="filterByStaker">{{ stake_account.staker }}</a></small>
              </td>
              <td class="word-break-md">
                {{ stake_account.pool_name }}
                <br />
                <small><a href="#" @click.prevent="filterByWithdrawer">{{ stake_account.withdrawer }}</a></small>
              </td>
              <td>
                {{ stake_account.activation_epoch }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})

export default StakeAccountRow
