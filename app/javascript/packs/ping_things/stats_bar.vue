<template>
  <div class="card mb-4">
    <div class="card-content">
      <div class="card-heading" v-if="titleVisible" data-turbolinks="false">
        <h2 class="h5 mb-2">Recent TX Confirmation Time&nbsp;Stats</h2>
        <a class="small" :href="pt_url">See details on the Ping Thing page</a>
      </div>

      <div class="row d-none d-lg-flex text-lg-center mb-1">
        <div class="col-lg-2">
          Stats
        </div>
        <div class="col-lg-2">
          <i class="fa-solid fa-calculator text-success me-2"></i>Entries
        </div>
        <div class="col-md-2">
          <i class="fa-solid fa-down-long text-success me-2"></i>Min
        </div>
        <div class="col-lg-2">
          <i class="fa-solid fa-divide text-success me-2"></i>Median
        </div>
        <div class="col-lg-2">
          <i class="fa-solid fa-up-long text-success me-2"></i>P90
        </div>
        <div class="col-lg-2">
          <i class="fa-solid fa-clock text-success me-2"></i>Latency
        </div>
      </div>

      <!-- stats -->
      <div class="row">
        <div class="col-sm-6 col-lg-12">

          <!-- 5 minutes stats -->
          <div class="row text-lg-center mb-3 mb-sm-0 mb-lg-1">
            <div class="col-lg-2 mb-1 mb-lg-0">5 min</div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-calculator text-success me-2"></i>Entries:&nbsp;
              </span>
              <span class="text-success">
                {{ last_5_mins["num_of_records"] ? last_5_mins["num_of_records"].toLocaleString('en-US') : '0' }}
              </span>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-down-long text-success me-2"></i>Min:&nbsp;
              </span>
              <span class="text-success">
                {{ last_5_mins["min"] ? last_5_mins["min"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-divide text-success me-2"></i>Median:&nbsp;
              </span>
              <span class="text-success">
                {{ last_5_mins["median"] ? last_5_mins["median"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-up-long text-success me-2"></i>P90:&nbsp;
              </span>
              <span class="text-success">
                {{ last_5_mins["p90"] ? last_5_mins["p90"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2">
              <span class="d-lg-none">
                <i class="fa-solid fa-clock text-success me-2"></i>Latency:&nbsp;
              </span>
              <span class="text-success">
                {{ last_5_mins["average_slot_latency"] ? last_5_mins["average_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + ' slots' : 'N / A' }}
              </span>
            </div>
          </div>
        </div>

        <!-- 1 hour stats -->
        <div class="col-sm-6 col-lg-12">
          <div class="row text-lg-center">
            <div class="col-lg-2 mb-1 mb-lg-0">1 hour</div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-calculator text-success me-2"></i>Entries:&nbsp;
              </span>
              <strong class="text-success">
                {{ last_60_mins["num_of_records"] ? last_60_mins["num_of_records"].toLocaleString('en-US') : '0' }}
              </strong>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-down-long text-success me-2"></i>Min:&nbsp;
              </span>
              <span class="text-success">
                {{ last_60_mins["min"] ? last_60_mins["min"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-divide text-success me-2"></i>Median:&nbsp;
              </span>
              <span class="text-success">
                {{ last_60_mins["median"] ? last_60_mins["median"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2 mb-1 mb-lg-0">
              <span class="d-lg-none">
                <i class="fa-solid fa-up-long text-success me-2"></i>P90:&nbsp;
              </span>
              <span class="text-success">
                {{ last_60_mins["p90"] ? last_60_mins["p90"].toLocaleString('en-US') + ' ms' : 'N / A' }}
              </span>
            </div>
            <div class="col-lg-2">
              <span class="d-lg-none">
                <i class="fa-solid fa-clock text-success me-2"></i>Latency:&nbsp;
              </span>
              <span class="text-success">
                {{ last_60_mins["average_slot_latency"] ? last_60_mins["average_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + ' slots' : 'N / A' }}
              </span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    props: {
      network: {
        default: "mainnet"
      },
      titleVisible: {
        default: false
      }
    },

    data () {
      var api_url = '/api/v1/ping-thing-recent-stats/' + this.network
      var pt_url = '/ping-thing?locale=en&network=' + this.network
      return {
        api_url: api_url,
        last_5_mins: {},
        last_60_mins: {},
        pt_url: pt_url
      }
    },

    created () {
      var ctx = this
      axios.get(ctx.api_url)
           .then(function(response) {
             ctx.last_5_mins = response.data.last_5_mins ? response.data.last_5_mins : {};
             ctx.last_60_mins = response.data.last_60_mins ? response.data.last_60_mins : {};
           })
    },

    channels: {
      PingThingRecentStatChannel: {
        connected() {},
        rejected() {},
        received(data) {
          data = JSON.parse(data)
          if(data["network"] == this.network) {
              switch(data["interval"]) {
                case 5:
                  this.last_5_mins = data
                  break
                case 60:
                  this.last_60_mins = data
                  break
              }
          }
        },
        disconnected() {},
      },
    },

    mounted: function() {
      this.$cable.subscribe({
          channel: "PingThingRecentStatChannel",
          room: "public",
        });
    },
    methods: {

    }
  }
</script>
