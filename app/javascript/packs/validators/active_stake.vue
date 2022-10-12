<template>
  <div>
    <span class="text-muted me-1">Active Stake:</span>

    <strong class="text-success">{{ total_active_stake }}</strong>
    <span class="text-muted" v-if="!total_active_stake">loading...</span>
  </div>
</template>

<script>
  import axios from 'axios';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  const network = 'mainnet';

  export default {
    data () {
      return {
        total_active_stake: null,
        api_url: '/api/v1/cluster-stats/' + network
      };
    },
    created() {
      const ctx = this;

      this.update_total_active_stake(ctx);

      setInterval(() => {
        this.update_total_active_stake(ctx);
      }, 300000);
    },
    methods: {
      lamports_to_sol(lamports) {
        return lamports / 1000000000;
      },
      update_total_active_stake(ctx) {
        axios.get(this.api_url)
             .then(function (response) {
               const stake = response.data.total_active_stake;
               ctx.total_active_stake = ctx.lamports_to_sol(stake).toLocaleString('en-US');
             })
      }
    },
  }
</script>
