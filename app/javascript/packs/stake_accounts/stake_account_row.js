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

  },
  template: `
    <tr>
      <td>
        {{ (stake_account.delegated_stake / 1000000000).toFixed(3) }} SOL
      </td>
      <td>
        <small>{{ stake_account.stake_pubkey }}</small>
        <br>
        <small>{{ stake_account.staker }}</small>
      </td>
      <td>
        {{ stake_account.name }}
        <br>
        <small>{{ stake_account.withdrawer }}</small>
      </td>
      <td>
        {{ stake_account.activation_epoch }}
      </td>
    </tr>
  `
})

export default StakeAccountRow
