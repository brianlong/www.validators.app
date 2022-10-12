<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Stake</h2>
        <div>
          <span class="text-muted me-1">Circulating Supply:</span>

          <span class="text-muted" v-if="!circulating_supply">loading...</span>
          <strong class="text-success" v-if="circulating_supply">{{ circulating_supply }} SOL</strong>
        </div>

        <small class="text-muted" v-if="total_circulating_supply">
          ({{ percent_of_total_stake() }}% of total {{ total_circulating_supply }} SOL)
        </small>
      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";

  export default {
    props: {
      network: {
        default: "mainnet-beta"
      }
    },
    data() {
      return {
        circulating_supply: null,
        total_circulating_supply: null,
        connection: new web3.Connection(web3.clusterApiUrl(this.network))
      }
    },
    created() {
      setInterval(() => {
        this.update_circulating_supply();
      }, 5000);
    },
    methods: {
      lamports_to_sol(lamports) {
        return lamports / 1000000000;
      },
      update_circulating_supply() {
        this.connection.getSupply()
          .then(response => {
            const val = response.value;
            this.circulating_supply = this.lamports_to_sol(val.circulating).toFixed(0).toLocaleString('en-US');
            this.total_circulating_supply = this.lamports_to_sol(val.total).toFixed(0).toLocaleString('en-US');
          });
      },
      percent_of_total_stake() {
        return (parseInt(this.circulating_supply) * 100 / parseInt(this.total_circulating_supply)).toFixed(0);
      }
    }
  }
</script>
