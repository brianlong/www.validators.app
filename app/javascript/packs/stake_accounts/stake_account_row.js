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

    }
  },
  watch: {

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
    <tr>
      <td>
        {{ (stake_account.delegated_stake / 1000000000).toFixed(3) }} SOL
      </td>
      <td>
        <small>{{ stake_account.stake_pubkey }}</small>
        <br>
        <small><a href="#" @click.prevent="filterByStaker">{{ stake_account.staker }}</a></small>
      </td>
      <td>
        {{ stake_account.name }}
        <br>
        <small><a href="#" @click.prevent="filterByWithdrawer">{{ stake_account.withdrawer }}</a></small>
      </td>
      <td>
        {{ stake_account.activation_epoch }}
      </td>
    </tr>
  `
})

export default StakeAccountRow
