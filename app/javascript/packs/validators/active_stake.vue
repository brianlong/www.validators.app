<template>
  <div>
    Active Stake:
    <strong class="text-success">{{ total_active_stake }}</strong>
  </div>
</template>

<script>
  import axios from 'axios';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    data () {
      return {
        total_active_stake: null,
        api_url: "/cluster-stats",
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
        axios.get(this.api_url, {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json'
          },
        }).then(function (response) {
          const stake = response.data.total_active_stake;
          ctx.total_active_stake = ctx.lamports_to_sol(stake).toLocaleString('en-US');
        })
      }
    },
  }
</script>
