import Vue from 'vue/dist/vue.esm'


var StakeAccountRow = Vue.component('StakeAccountRow', {
  props: {
    stake_account: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      validator_url: "/validators/" + this.stake_account.validator_account + "?network=" + this.stake_account.network
    }
  },
  methods: {
    filterByStaker: function(e) {
      this.$emit('filter_by_staker', this.stake_account.staker);
    },
    filterByWithdrawer: function(e) {
      this.$emit('filter_by_withdrawer', this.stake_account.withdrawer);
    },
    name_or_account: function() {
      if (this.stake_account.validator_name) {
        return this.stake_account.validator_name
      } else if (this.stake_account.validator_account) {
        return this.stake_account.validator_account.substring(0,5) + "..." + this.stake_account.validator_account.substring(this.stake_account.validator_account.length - 5)
      } else {
        return ''
      }
    }
  },
  template: `
    <tr>
      <td>
        {{ (stake_account.delegated_stake / 1000000000).toFixed(3) }} SOL
        <br />
        <small>
          <a :href="validator_url" target="_blank">{{ name_or_account() }}</a>
        </small>
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
  `
})

export default StakeAccountRow
