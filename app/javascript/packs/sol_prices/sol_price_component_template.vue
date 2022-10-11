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

          <small class="text-success" v-if="change_24h > 0">
            <i class="fas fa-long-arrow-alt-up" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
          <small class="text-danger" v-if="change_24h < 0">
            <i class="fas fa-long-arrow-alt-down" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
        </div>

        <div class=" small">
          <span class="text-muted me-1">24h volume:</span>
          <span class="text-success" v-if="volume_24h">
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
      SolPriceChannel: {
        connected() {},
        rejected() {},
        received(data) {
          this.price = data.result.last.toFixed(2)
          this.change_24h = (data.result.change24h * 100).toFixed(2)
          this.volume_24h = data.result.volumeUsd24h.toFixed(0)
        },
        disconnected() {},
      },
    },
    mounted: function(){
      this.$cable.subscribe({
          channel: "SolPriceChannel",
          room: "public",
        });
    },
  }
</script>
