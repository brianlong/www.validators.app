<template>
  <div class="col-lg-4 col-md-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">SOL Price</h2>

        <div class="mb-1">
          <span class="text-muted me-1">Current:</span>
          <strong class="text-success me-2" v-if="price">
            <i class="fa-solid fa-dollar-sign me-1"></i>{{ price }}
          </strong>
          <span class="text-muted" v-if="!price">loading...</span>

          <small class="text-success text-nowrap" v-if="change_24h > 0">
            <i class="fa-solid fa-up-long" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
          <small class="text-danger text-nowrap" v-if="change_24h < 0">
            <i class="fa-solid fa-down-long" aria-hidden="true"></i>
            {{ change_24h }}%
          </small>
        </div>

        <div class=" small">
          <span class="text-muted me-1">24h volume:</span>
          <span class="text-success" v-if="volume_24h">
            <i class="fa-solid fa-dollar-sign me-1"></i>
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
  import axios from 'axios';

  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    data() {
      return {
        price: null,
        change_24h: null,
        volume_24h: null,
        init_price: null,
        init_change_24h: null,
        init_volume_24h: null
      }
    },
    created() {
      const ctx = this
      const url = "/api/v1/sol-prices"

      axios.get(url)
        .then(response => {
          const data = response.data

          ctx.init_price = data[0].average_price
          ctx.init_change_24h = -(data[1].average_price - data[0].average_price)
          ctx.init_volume_24h = data[0].volume
          ctx.price = (+ctx.init_price).toFixed(2)
          ctx.change_24h = (+ctx.init_change_24h).toFixed(2)
          ctx.volume_24h = (+ctx.init_volume_24h).toLocaleString('en-US', { maximumFractionDigits: 0 })
        })
    },
    channels: {
      FrontStatsChannel: {
        connected() {},
        rejected() {},
        received(data) {
          if (data.solana) {
            this.price = data.solana.usd
            this.change_24h = data.solana.usd_24h_change
            this.volume_24h = data.solana.usd_24h_vol
          } else {
            this.price = this.init_price
            this.change_24h = this.init_change_24h
            this.volume_24h = this.init_volume_24h
          }

          this.price = (+this.price).toFixed(2)
          this.change_24h = (+this.change_24h).toFixed(2)
          this.volume_24h = (+this.volume_24h).toLocaleString('en-US', { maximumFractionDigits: 0 })
        },
        disconnected() {},
      },
    },
    mounted: function() {
      this.$cable.subscribe({
          channel: "FrontStatsChannel",
          room: "public",
        });
    },
  }
</script>
