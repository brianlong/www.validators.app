<template>
  <div>
    <div>
      Circulating Supply:
      <strong class="text-success">{{ circulating_supply }}</strong>
    </div>
    <div>
      of total:
      <strong class="text-success">{{ total_circulating_supply }}</strong>
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
