<template>
  <div>
    Circulating Supply:
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js";

  export default {
    props: {
      network: {
        // TODO: default: "mainnet-beta"
        default: "devnet"
      },
    },
    created() {
      const connection = new web3.Connection(web3.clusterApiUrl(this.network));

      connection.getSupply().then(response => {
        console.log('response', response.value);
      });
    }
  }
</script>
