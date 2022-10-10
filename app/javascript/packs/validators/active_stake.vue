<template>
  <div>
    Total Active Stake: {{ total_active_stake }}
    of(%):
  </div>
</template>

<script>
  import axios from 'axios';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    props: {
      network: {
        // TODO: default: "mainnet-beta"
        default: "devnet"
      },
    },
    data () {
      return {
        total_active_stake: 0
      };
    },
    methods: {
    },
    created() {
      const ctx = this;
      const api_url = "/cluster-stats";

      axios.get(api_url, {
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json'
        },
      }).then(function (response) {
        ctx.total_active_stake = response.data.total_active_stake;
      })
    },
    mounted: function () {
    },
  }
</script>
