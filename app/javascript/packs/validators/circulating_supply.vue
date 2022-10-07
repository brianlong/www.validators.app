<template>
  <div>
    Circulating Supply:
    of(%):
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
  }
</script>
