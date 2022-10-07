<template>
  <div>
    Total Active Stake:
    of(%):
  </div>
</template>

<script>
export default {
  props: {
    network: {
      // TODO: default: "mainnet-beta"
      default: "devnet"
    },
  },
  data () {
    return {total_active_stake: 0};
  },
  channels: {
    ClusterStatChannel: {
      connected() {
        console.log("connected to ClusterStatChannel");
        console.log("this", this);
      },
      rejected() { },
      received(data) {
        var new_stat = JSON.parse(data)

      },
      disconnected() { },
    },
  },
  created: function () {
    
  },
  mounted: function () {
    this.$cable.subscribe({
      channel: "ClusterStatChannel",
      room: "public",
    });
  },
}
</script>
