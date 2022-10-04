<template>
  Active Stake:
  of(%):
</template>

<script>
  import * as Web3 from "@solana/web3.js";

  export default {
    props: {
      network: {
        // TODO: default: "mainnet-beta"
        default: "devnet"
      },
    },
    channels: {
      ActiveStakeChannel: {
        connected() { console.log('ActiveStakeChannel connected') },
        rejected() { },
        received(data) {
          console.log('data', data);
        },
        disconnected() { },
      },
    },
    mounted: function () {
      this.$cable.subscribe({
        channel: "ActiveStakeChannel",
        room: "public",
      });
    },
  }
</script>
