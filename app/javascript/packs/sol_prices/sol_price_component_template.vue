<template>
  <div class="card col-md-3 col-sm-6">
    <div class="card-content">
      <div class="col-12 stat-title-4">
        sol price: 
        <strong class="text-success" v-if="price">
          <i class="fas fa-dollar-sign px-2"></i>{{price}}
        </strong>
        <strong class="text-muted" v-if="!price">
          loading ...
        </strong>
      </div>
    </div>
  </div>
</template>

<script>

  export default {
    data() {
      return {
        price: null
      }
    },
    methods: {
      
    },
    channels: {
      SolPriceChannel: {
        connected() {},
        rejected() {},
        received(data) {
          console.log(data.result)
          this.price = data.result.last.toFixed(2)
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
