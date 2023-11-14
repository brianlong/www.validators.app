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
    },
    current_epoch: {
      type: Number,
      required: true
    }
  },

  data() {
    return {
      validator: null,
      stake_accounts_for_val: null,
      val_account: Object.keys(this.stake_accounts)[0]
    }
  },

  created () {
    this.stake_accounts_for_val = this.stake_accounts[this.val_account]

    var ctx = this
    if(this.val_account) {
      axios.get('/api/v1/validators/' + this.stake_accounts_for_val[0]["network"] + '/' + this.val_account + '?with_history=true')
           .then(function (response) {
             ctx.validator = response.data
           })
    }
  },

  methods: {
    stake_acc_details_link: function (stake_pubkey) {
      return '/stake-explorer/' + stake_pubkey
    },

    stake_explorer_withdrawer_link: function (withdrawer) {
      return "/stake-explorer?network=" + this.stake_accounts_for_val[0]["network"] + "&withdrawer=" + withdrawer
    },

    stake_explorer_staker_link: function (staker) {
      return "/stake-explorer?network=" + this.stake_accounts_for_val[0]["network"] + "&staker=" + staker
    }
  },

  template: `
    <tbody>
      <validator-row :validator="validator" :idx="idx" :batch="batch" v-if="validator"/>
      
      <tr>
        <td colspan="6" class="p-0">
          <table class="table table-block-sm stake-accounts-table">
            <thead>
              <tr>
                <th class="column-xxs d-none d-xl-table-cell"></th>
                <th class="column-xl small">Stake Account & Staker</th>
                <th class="column-xl small">Withdrawer</th>
                <th class="column-sm">Stake</th>
                <th class="column-xs text-lg-end ps-lg-0">
                  Act Epoch&nbsp;<i class="fa-solid fa-circle-info font-size-xs text-muted ms-1"
                                    data-bs-toggle="tooltip"
                                    data-bs-placement="top"
                                    title="Stake Account Activation Epoch">
                                 </i><br />
                  <small class="text-muted">Current: {{ current_epoch }}</small>
                </th>
              </tr>
            </thead>
            
            <tbody class="small">
            <tr v-for="stake_account in stake_accounts_for_val" :key="stake_account.id" v-if="validator">
              <td class="text-center pe-0 d-none d-xl-table-cell">
                <img class="img-sm"
                     :title="stake_account.pool_name"
                     :src="stake_pool_small_logo(stake_account.pool_name)" />
              </td>
              <td class="word-break">
                <strong class="d-inline-block d-lg-none">Stake Account:&nbsp;&nbsp;</strong>
                <a :href="stake_acc_details_link(stake_account.stake_pubkey)">{{ stake_account.stake_pubkey }}</a>
                <div class="text-muted">
                  <strong class="d-inline-block d-lg-none">Staker:&nbsp;&nbsp;</strong>
                  <a :href="stake_explorer_staker_link(stake_account.staker)">{{ stake_account.staker }}</a>
                </div>
              </td>
              <td class="word-break">
                <strong class="d-inline-block d-lg-none">Withdrawer:&nbsp;&nbsp;</strong>{{ stake_account.pool_name }}
                <div class="text-muted">
                  <a :href="stake_explorer_withdrawer_link(stake_account.withdrawer)">{{ stake_account.withdrawer }}</a>
                </div>
              </td>
              <td>
                <strong class="d-inline-block d-lg-none">Stake:&nbsp;</strong>
                <span v-if="stake_account.active_stake < 500000000">
                  <0.5 SOL<br />
                  <span class="text-muted">
                    {{ ((stake_account.active_stake / stake_account.validator_active_stake) * 100).toLocaleString('en-US', {maximumFractionDigits: 2}) }}% of validator's stake
                  </span>
                </span>
                <span v-else>
                  {{ (stake_account.active_stake / 1000000000).toLocaleString('en-US', {maximumFractionDigits: 0}) }} SOL
                  <br />
                  <span class="text-muted">
                    {{ ((stake_account.active_stake / stake_account.validator_active_stake) * 100).toLocaleString('en-US', {maximumFractionDigits: 2}) }}% of validator's stake
                  </span>
                </span>
              </td>
              <td class="text-lg-end">
                <strong class="d-inline-block d-lg-none">Stake Account Activation Epoch:&nbsp;&nbsp;</strong>{{ stake_account.activation_epoch }}
                <div class="d-block d-lg-none">
                  <small class="text-muted">Current Epoch: {{ current_epoch }}&nbsp;&nbsp;</small>
                </div>
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
