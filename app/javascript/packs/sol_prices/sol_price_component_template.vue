<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">SOL Price</h2>

        <div class="mb-1">
          <span class="text-muted me-1">Current:</span>
          <strong class="text-success me-2" v-if="price">
            <i class="fas fa-dollar-sign me-1"></i>{{ price }}
          </strong>
          <span class="text-muted" v-if="!price">loading...</span>

          <small class="text-success text-nowrap" v-if="change_24h > 0">
            <i class="fas fa-long-arrow-alt-up" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
          <small class="text-danger text-nowrap" v-if="change_24h < 0">
            <i class="fas fa-long-arrow-alt-down" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
        </div>

        <div class=" small">
          <span class="text-muted me-1">24h volume:</span>
          <span class="text-success" v-if="volume_24h">
            <i class="fas fa-dollar-sign me-1"></i>
            {{ volume_24h }}
          </span>
          <span class="text-muted" v-if="!volume_24h">
            loading...
          </span>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        price: null,
        change_24h: null,
        volume_24h: null
      }
    },
    methods: {

    },
    channels: {
      FrontStatsChannel: {
        connected() {},
        rejected() {},
        received(data) {
          this.price = data.solana.usd.toFixed(2)
          this.change_24h = data.solana.usd_24h_change.toFixed(2)
          this.volume_24h = data.solana.usd_24h_vol.toLocaleString('en-US', { maximumFractionDigits: 0 })
        },
        disconnected() {},
      },
    },
    mounted: function(){
      this.$cable.subscribe({
          channel: "FrontStatsChannel",
          room: "public",
        });
    },
  }
</script>
