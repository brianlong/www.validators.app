<template>
  <div class="card mb-4">
    <div class="card-content pb-0" v-if="titleVisible" data-turbolinks="false">
      <div class="text-center mb-3">
        <h2 class="h5 mb-2">Recent TX Confirmation Time&nbsp;Stats</h2>
        <a class="small" :href="pt_url">See details on the Ping Thing page</a>
      </div>
    </div>

    <div class="table-responsive-lg">
      <table class="table text-center">
        <thead>
        <tr>
          <th class="column-sm px-0">Stats</th>
          <th class="column-xs px-0">
            <i class="fa-solid fa-calculator text-success me-2"></i>Entries
          </th>
          <th class="column-sm px-0">
            <i class="fa-solid fa-circle-xmark text-success me-2"></i>Errors
          </th>
          <th class="column-xl px-0" colspan="3">
            <i class="fa-solid fa-clock text-success me-2"></i>Time (ms)<br />
            <small class="text-muted text-small">min / median / p90</small>
          </th>
          <th class="column-lg px-0" colspan="3">
            <i class="fa-solid fa-stopwatch text-success me-2"></i>Slot Latency<br />
            <small class="text-muted text-small">min / median / p90</small>
          </th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <td class="fw-bold">5&nbsp;min</td>
          <td class="text-success">
            {{ (last_5_mins["num_of_records"] || last_5_mins["num_of_records"] === 0) ? last_5_mins["num_of_records"].toLocaleString('en-US') : '0' }}
          </td>
          <td class="text-success text-nowrap">
            {{ (last_5_mins["fails_count"] || last_5_mins["fails_count"] === 0) ? last_5_mins["fails_count"].toLocaleString('en-US') : 'N / A' }}
            <span class="text-muted text-small">
              {{ fails_count_percentage(last_5_mins["fails_count"], last_5_mins["num_of_records"]) }}
            </span>
          </td>
          <td class="text-success-darker text-nowrap ps-5">
            {{ last_5_mins["min"] ? last_5_mins["min"].toLocaleString('en-US') : 'N / A' }}
          </td>
          <td class="text-success text-nowrap px-0">
            {{ last_5_mins["median"] ? last_5_mins["median"].toLocaleString('en-US') : 'N / A' }}
          </td>
          <td class="text-success-darker text-nowrap pe-5">
            {{ last_5_mins["p90"] ? last_5_mins["p90"].toLocaleString('en-US') : 'N / A' }}
          </td>

          <td class="text-success-darker text-nowrap ps-4 ps-lg-5">
            {{ (typeof last_5_mins["min_slot_latency"] !== 'undefined') ? last_5_mins["min_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_5_mins["min_slot_latency"], 'slot') : 'N / A' }}
          </td>
          <td class="text-success text-nowrap ps-0 ps-xl-1 pe-0">
            {{ (typeof last_5_mins["average_slot_latency"] !== 'undefined') ? last_5_mins["average_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_5_mins["average_slot_latency"], 'slot') : 'N / A' }}
          </td>
          <td class="text-success-darker text-nowrap pe-4 pe-lg-5">
            {{ (typeof last_5_mins["p90_slot_latency"] !== 'undefined') ? last_5_mins["p90_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_5_mins["p90_slot_latency"], 'slot') : 'N / A' }}
          </td>
        </tr>
        <tr>
          <td class="fw-bold">1&nbsp;hour</td>
          <td class="text-success">
            {{ (last_60_mins["num_of_records"] || last_60_mins["num_of_records"] === 0) ? last_60_mins["num_of_records"].toLocaleString('en-US') : '0' }}
          </td>
          <td class="text-success text-nowrap">
            {{ (last_60_mins["fails_count"] || last_60_mins["fails_count"] === 0) ? last_60_mins["fails_count"].toLocaleString('en-US') : 'N / A' }}
            <span class="text-muted text-small">
              {{ fails_count_percentage(last_60_mins["fails_count"], last_60_mins["num_of_records"]) }}
            </span>
          </td>
          <td class="text-success-darker text-nowrap ps-5">
            {{ last_60_mins["min"] ? last_60_mins["min"].toLocaleString('en-US') : 'N / A' }}
          </td>
          <td class="text-success text-nowrap px-0">
            {{ last_60_mins["median"] ? last_60_mins["median"].toLocaleString('en-US') : 'N / A' }}
          </td>
          <td class="text-success-darker text-nowrap pe-5">
            {{ last_60_mins["p90"] ? last_60_mins["p90"].toLocaleString('en-US') : 'N / A' }}
          </td>

          <td class="text-success-darker text-nowrap ps-4 ps-lg-5">
            {{ (typeof last_60_mins["min_slot_latency"] !== 'undefined') ? last_60_mins["min_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_60_mins["min_slot_latency"], 'slot') : 'N / A' }}
          </td>
          <td class="text-success text-nowrap ps-0 ps-xl-1 pe-0">
            {{ (typeof last_60_mins["average_slot_latency"] !== 'undefined') ? last_60_mins["average_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_60_mins["average_slot_latency"], 'slot') : 'N / A' }}
          </td>
          <td class="text-success-darker text-nowrap pe-4 pe-lg-5">
            {{ (typeof last_60_mins["p90_slot_latency"] !== 'undefined') ? last_60_mins["p90_slot_latency"].toLocaleString('en-US', {maximumFractionDigits: 1}) + pluralize(last_60_mins["p90_slot_latency"], 'slot') : 'N / A' }}
          </td>
        </tr>
        </tbody>
      </table>
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
    }
  }
</script>
