<template>
  <section>
    <div class="d-flex justify-content-between flex-wrap flex-column flex-md-row gap-3 mb-4">
      <div class="d-flex flex-wrap flex-column flex-md-row gap-3">
        <div>
          <input name="filter_time"
                 v-model="filter_time"
                 type="number"
                 class="form-control"
                 step="10"
                 placeholder="Minimum time (ms)"
                 v-on:keyup.enter="get_records()">
        </div>
        <div>
          <input name="posted_by"
                 v-model="posted_by"
                 type="text"
                 class="form-control"
                 placeholder="Posted By"
                 v-on:keyup.enter="get_records()">
        </div>
        <div>
          <select name="success"
                  v-model="success"
                  class="form-select form-control"
                  v-on:keyup.enter="get_records()">
            <option value="" selected>Status (all)</option>
            <option value="true">success</option>
            <option value="false">failure</option>
          </select>
        </div>

        <button @click.prevent="get_records()"
                class="btn btn-sm btn-primary"
                style="width: 115px;">
          Search
        </button>
      </div>

      <button @click.prevent="reset_filters()"
              class="btn btn-sm btn-tertiary"
              v-if="filters_present()"
              style="width: 115px;">
        Reset filters
      </button>
    </div>

    <div class="card">
      <div class="table-responsive-lg">
        <table class='table' v-if="ping_things.length > 0">
          <thead>
          <tr>
            <th class="column-md-sm">Success / Time</th>
            <th class="column-lg">
              Reported&nbsp;At<br />
              <span class="small text-muted">Signature</span>
            </th>
            <th class="column-lg">
              Application<br />
              <span class="small text-muted">Type (Commitment Level)</span>
            </th>
            <th class="column-lg">
              <span class="text-muted">Slot Sent</span><br />
              <span class="text-muted">Slot Landed</span> (Latency)
            </th>
            <th class="column-xs">Posted&nbsp;By</th>
          </tr>
          </thead>

          <tbody>
          <tr v-for="pt in ping_things" :key="pt.id">
            <td class="text-nowrap">
              <span v-html="success_icon(pt.success)"></span>
              <strong class="text-success h6">{{ pt.response_time.toLocaleString('en-US') }}</strong>&nbsp;ms
            </td>
            <td class="small">
              {{ date_time_with_timezone(pt.reported_at) }}<br />
              <span class="word-break">
                <a :href="link_from_signature(pt.signature)" target="_blank" class="small">
                  {{ signature_shortened(pt.signature) }}
                </a>
              </span>
            </td>
            <td class="small">
              <div v-if="pt.application">
                {{ pt.application }}<br />
              </div>
              <span class="text-muted">
                <span v-html="transaction_type_icon(pt.transaction_type)"></span>
                {{ pt.transaction_type }}
                <span v-if="pt.commitment_level">({{ pt.commitment_level }})</span>
              </span>
            </td>
            <td class="small">
              <span class="text-muted">{{ pt.slot_sent }}</span><br />
              <span class="text-muted">{{ pt.slot_landed }}</span> ({{ slot_latency(pt.slot_sent, pt.slot_landed) }})
            </td>
            <td>
              <a href="" title="Filter by this sender" @click.prevent="filter_by_posted_by(pt.username)">{{ pt.username }}</a>
            </td>
          </tr>
          </tbody>
        </table>
        <div class="card-content text-center" v-else>
          No records found.
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import '../mixins/dates_mixins'
  import axios from 'axios'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: {
      network: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        ping_things: [],
        api_url: '/api/v1/ping-thing/' + this.network,
        limit: 60,

        // filters
        filter_time: null,
        posted_by: null,
        success: ""
      }
    },

    created () {
      this.get_records()
    },

    channels: {
      PingThingChannel: {
        connected() {},
        rejected() {},
        received(data) {
          if(this.matches_network(data) && this.matches_filters(data)) {
            this.ping_things.unshift(data)
            if(this.ping_things.length > this.limit) {
              this.ping_things.pop()
            }
          }
        },
        disconnected() {},
      },
    },

    methods: {
      matches_network(data) {
        if(data["network"] == this.network) {
          return true
        } else {
          return false
        }
      },

      matches_filters(data) {
        if(this.filter_time) {
          let time = parseInt(data["response_time"])
          if(time < parseInt(this.filter_time)) {
            return false
          }
        }
        if(this.posted_by) {
          let username = data["username"]
          let posted_by_regexp = new RegExp("^" + this.posted_by.toString());
          if(!posted_by_regexp.test(username)) {
            return false
          }
        }
        if(this.success) {
          let success = data["success"].toString()
          if(success != this.success.toString()) {
            return false
          }
        }
        return true
      },

      success_icon(success) {
        if(success) {
          return '<i class="fa-solid fa-circle-check text-success me-1"></i>'
        } else {
          return '<i class="fa-solid fa-circle-xmark text-danger me-1"></i>'
        }
      },

      link_from_signature(signature) {
        return "https://explorer.solana.com/tx/" + signature
      },

      transaction_type_icon(tx) {
        switch(tx) {
          case 'transfer':
            return '<i class="fa-solid fa-right-left text-success me-1"></i>'
          default:
            return '<i class="fa-solid fa-shuffle text-success me-1"></i>'
        }
      },

      signature_shortened(signature) {
        return signature.substring(0,6) + "..." + signature.substring(signature.length - 4, signature.length)
      },

      slot_latency(sent, landed) {
        if(sent && landed) {
          return landed - sent
        } else {
          return " - "
        }
      },

      filter_by_posted_by(username) {
        this.posted_by = username;
        this.get_records();
      },

      get_records() {
        let ctx = this
        let filters = {
          time_filter: ctx.filter_time,
          posted_by: ctx.posted_by,
          success: ctx.success,
          limit: this.limit
        }

        axios.get(ctx.api_url, { params: filters })
             .then(function(response) {
               ctx.ping_things = response.data;
             })
      },

      reset_filters() {
        this.filter_time = null
        this.posted_by = null
        this.success = ""
        this.get_records()
      },

      filters_present() {
        if(this.filter_time || this.posted_by || this.success) {
          return true
        } else {
          return false
        }
      }
    }
  }
</script>
