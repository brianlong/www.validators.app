<template>
  Circulating Supply:
  of(%):
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
    channels: {
      CirculatingSupplyChannel: {
        connected() {
          let connection = new web3.Connection(web3.clusterApiUrl(this.default));

          console.log('connection', connection);
          console.log('connection.getSupply', connection.getSupply);

        },
        rejected() { },
        received(data) {
          console.log('data', data);
        },
        disconnected() { },
      },
    },
    mounted: function () {
      this.$cable.subscribe({
        channel: "CirculatingSupplyChannel",
        room: "public",
      });
    }
  }
</script>
