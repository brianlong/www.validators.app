<template>
  <div>
    <span class="text-muted me-1">Circulating:</span>
    <strong class="text-success">{{ circulating_supply }}</strong>
    <small class="small">(X% of {{ total_circulating_supply }})</small>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";

  export default {
    props: {
      network: {
        // TODO: default: "mainnet-beta"
        default: "devnet"
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
      this.update_circulating_supply();

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
            this.circulating_supply = this.lamports_to_sol(val.circulating).toLocaleString('en-US');
            this.total_circulating_supply = this.lamports_to_sol(val.total).toLocaleString('en-US');
          });
      }
    }
  }
</script>
