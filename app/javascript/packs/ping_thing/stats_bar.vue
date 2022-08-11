<template>
  <div class="card mb-4">
      <div class="card-content">
        <h2 class="h3 card-heading" v-if="titleVisible">
          Recent TX Confirmation Time Stats
        </h2>
        <div class="row px-xl-4 ping-thing-stats-header">
          <div class="col-lg-2 px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-none d-lg-block">Stats from&nbsp;</span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center d-none d-lg-block">
            <span class="stat-title-4">
              <i class="fas fa-calculator text-success mr-2"></i>
              Entries&nbsp;
            </span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center d-none d-lg-block">
            <span class="stat-title-4">
              <i class="fas fa-long-arrow-alt-down text-success mr-1"></i>
              Min&nbsp;
            </span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center d-none d-lg-block">
            <span class="stat-title-4">
              <i class="fas fa-divide text-success mr-1"></i>
              Median&nbsp;
            </span>
          </div>
          <div class="col-md-6 col-lg px-md-0 text-md-center d-none d-lg-block">
            <span class="stat-title-4">
              <i class="fas fa-long-arrow-alt-up text-success mr-1" aria-hidden="true"></i>
              P90&nbsp;
            </span>
          </div>
        </div>

        <div class="row px-xl-4 mt-2 text-lg-left text-center">
          <div class="col-lg-2 px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-3 d-lg-none">5 min stats&nbsp;</span>
            <span class="stat-title-4 d-none d-lg-block">5 min&nbsp;</span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-calculator text-success mr-2"></i>
              Entries:&nbsp;
            </span>
            <strong class="text-success">{{ last_5_mins["num_of_records"] ? last_5_mins["num_of_records"].toLocaleString() : '0' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-long-arrow-alt-down text-success mr-1"></i>
              Min:&nbsp;
            </span>
            <strong class="text-success">{{ last_5_mins["min"] ? last_5_mins["min"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-divide text-success mr-1"></i>
              Median:&nbsp;
            </span>
            <strong class="text-success">{{ last_5_mins["median"] ? last_5_mins["median"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 text-md-center">
             <span class="stat-title-4 d-lg-none">
              <i class="fas fa-long-arrow-alt-up text-success mr-1" aria-hidden="true"></i>
              P90:&nbsp;
            </span>
            <strong class="text-success">{{ last_5_mins["p90"] ? last_5_mins["p90"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
        </div>

        <div class="row px-xl-4 mt-2 text-lg-left text-center">
          <div class="col-lg-2 px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-3 d-lg-none">1 hour stats&nbsp;</span>
            <span class="stat-title-4 d-none d-lg-block">1 hour&nbsp;</span>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-calculator text-success mr-2"></i>
              Entries:&nbsp;
            </span>
            <strong class="text-success">{{ last_60_mins["num_of_records"] ? last_60_mins["num_of_records"].toLocaleString() : '0' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-long-arrow-alt-down text-success mr-1"></i>
              Min:&nbsp;
            </span>
            <strong class="text-success">{{ last_60_mins["min"] ? last_60_mins["min"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 mb-3 mb-lg-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-divide text-success mr-1"></i>
              Median:&nbsp;
            </span>
            <strong class="text-success">{{ last_60_mins["median"] ? last_60_mins["median"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
          <div class="col-md-6 col-lg px-md-0 text-md-center">
            <span class="stat-title-4 d-lg-none">
              <i class="fas fa-long-arrow-alt-up text-success mr-1" aria-hidden="true"></i>
              P90:&nbsp;
            </span>
            <strong class="text-success">{{ last_60_mins["p90"] ? last_60_mins["p90"].toLocaleString() + ' ms' : 'N / A' }}</strong>
          </div>
        </div>
        <div class="mt-4 text-center text-muted" data-turbolinks="false" v-if="titleVisible">
          See details on the <a :href="pt_url">Ping Thing</a> page.
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
          if(data["network"] == this.network){
              switch(data["interval"]){
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
    mounted: function(){
      this.$cable.subscribe({
          channel: "PingThingRecentStatChannel",
          room: "public",
        });
    },
    methods: {

    }
  }
</script>
