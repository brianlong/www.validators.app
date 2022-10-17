<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Stake</h2>
        <div>
          <span class="text-muted me-1">Circulating Supply:</span>

          <span class="text-muted" v-if="!circulating_supply">loading...</span>
          <strong class="text-success" v-if="circulating_supply">{{ circulating_supply }}&nbsp;SOL</strong>
        </div>

        <div>
          <span class="text-muted me-1">Total Active Stake:</span>

          <span class="text-muted" v-if="!total_active_stake">loading...</span>
          <strong class="text-success" v-if="total_active_stake">{{ total_active_stake }}&nbsp;SOL</strong>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";
  import { mapGetters } from 'vuex'

  export default {
    props: {
      network: {
        default: "mainnet-beta"
      }
    },
    data() {
      return {
        connection: null,
        circulating_supply: null,
        total_circulating_supply: null,
        total_active_stake: null,
        api_params: { excludeNonCirculatingAccountsList: true }
      }
    },
    created() {
      this.connection = new web3.Connection(this.web3_url);

      this.update_circulating_supply();
      this.set_continuous_supply_update();
    },
    mounted: function(){
      this.$cable.subscribe({
          channel: "SolPriceChannel",
          room: "public",
        });
    },
    computed: mapGetters([
      'web3_url'
    ]),
    channels: {
      SolPriceChannel: {
        connected() {},
        rejected() {},
        received(data) {
          var stake = data.cluster_stats["mainnet"]["total_active_stake"] // TODO alternate mainnet/testnet
          this.total_active_stake = this.lamports_to_sol(stake).toLocaleString('en-US', { maximumFractionDigits: 0 });
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
      },
      set_continuous_supply_update() {
        setInterval(() => {
          this.update_circulating_supply();
        }, 5000);
      }
    }
  }
</script>
