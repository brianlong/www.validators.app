<template>
  <div class="card col-md-3 col-sm-6">
    <div class="card-content">
      <div class="row">
        <div class="col-12 stat-title-4 mb-2">
          sol price: 
          <strong class="text-success" v-if="price">
            <i class="fas fa-dollar-sign px-1"></i>{{ price }}
          </strong>
          <strong class="text-muted" v-if="!price">
            loading ...
          </strong>
        </div>
        <div class="col-6 small">
          24h change:<br />
          <span :class="change_24h > 0 ? 'text-success' : 'text-danger' ">
            {{ change_24h }}
          </span>
        </div>
        <div class="col-6 small">
          24h volume:<br />
          <span class="text-success">
            {{ volume_24h }}
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
          this.change_24h = data.result.change24h.toFixed(4)
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
