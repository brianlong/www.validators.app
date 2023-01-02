<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Stake</h2>
        <div class="mb-2">
          <span class="text-muted me-1">Active Stake:</span>

          <span class="text-muted" v-if="!total_active_stake">loading...</span>
          <strong class="text-success" v-if="total_active_stake">{{ total_active_stake }}&nbsp;SOL</strong>
        </div>

        <div class="mb-2">
          <span class="text-muted me-1">Circulating Supply:</span>

          <span class="text-muted" v-if="!circulating_supply">loading...</span>
          <strong class="text-success" v-if="circulating_supply">{{ circulating_supply }}&nbsp;SOL</strong>
          <div class="small text-muted" v-if="total_circulating_supply">
            ({{ percent_of_total_stake() }}% of total {{ total_circulating_supply }}&nbsp;SOL)
          </div>
        </div>

        <div class="mb-2">
          <span class="text-muted me-1">Gross Yield:</span>

          <span class="text-muted" v-if="!gross_yield">loading...</span>
          <span v-if="gross_yield">
            <strong class="text-success">{{ gross_yield }}%</strong>
            <div class="small text-muted">
              (Last 3 epochs annualized)
            </div>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        connection: null,
        circulating_supply: null,
        total_circulating_supply: null,
        total_active_stake: null,
        api_params: { excludeNonCirculatingAccountsList: true },
        gross_yield: null
      }
    },
    created() {
      this.connection = new web3.Connection(this.web3_url);

      this.update_circulating_supply();
    },
    mounted: function(){
      this.$cable.subscribe({
          channel: "FrontStatsChannel",
          room: "public",
        });
    },
    computed: mapGetters([
      'web3_url',
      'network'
    ]),
    channels: {
      FrontStatsChannel: {
        connected() {},
        rejected() {},
        received(data) {
          const stake = data.cluster_stats[this.network].total_active_stake;
          this.total_active_stake = this.lamports_to_sol(stake).toLocaleString('en-US', { maximumFractionDigits: 0 });

          const total_rewards = this.lamports_to_sol(data.cluster_stats[this.network].total_rewards);
          this.gross_yield = (parseInt(total_rewards) * 100 / parseInt(this.total_active_stake)).toFixed(2);
        },
        disconnected() {},
      },
    },
    methods: {
      lamports_to_sol(lamports) {
        return lamports / 1000000000;
      },
      update_circulating_supply() {
        this.connection.getSupply(this.api_params)
          .then(response => {
            const val = response.value;
            this.circulating_supply = this.lamports_to_sol(val.circulating).toLocaleString('en-US', { maximumFractionDigits: 0 });
            this.total_circulating_supply = this.lamports_to_sol(val.total).toLocaleString('en-US', { maximumFractionDigits: 0 });
          });
      },
      percent_of_total_stake() {
        return (parseInt(this.circulating_supply) * 100 / parseInt(this.total_circulating_supply)).toFixed(0);
      }
    }
  }
</script>
