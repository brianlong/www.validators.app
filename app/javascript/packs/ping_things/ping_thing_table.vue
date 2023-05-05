<template>
  <section>
    <div class="d-flex justify-content-between flex-wrap gap-3 mb-4">
      <div class="form-group-row">
        <div class="input-group">
          <input name="filter_time"
                 @keyup.enter="get_filtered_records()"
                 v-model="filter_time"
                 type="number"
                 class="form-control"
                 step="10"
                 placeholder="Minimum time (ms)">
          <button @click.prevent="get_filtered_records()"
                  class="btn btn-sm btn-primary">
            Search
          </button>
        </div>
      </div>

      <button @click.prevent="reset_filter()"
              class="btn btn-sm btn-tertiary"
              v-if="show_filtered_records">
        Reset filters
      </button>
    </div>

    <div class="card">
      <div class="table-responsive-lg">
        <table class='table' v-if="all_or_filtered.length > 0">
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
            <tr v-for="(pt) in all_or_filtered" :key="pt.id">
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
                  <span v-if="pt.commitment_level">
                    ({{ pt.commitment_level }})
                  </span>
                </span>
              </td>
              <td class="small">
                <span class="text-muted">{{ pt.slot_sent }}</span> <br />
                <span class="text-muted">{{ pt.slot_landed }}</span> ({{ slot_latency(pt.slot_sent, pt.slot_landed) }})
              </td>
              <td class="text-muted">{{ pt.username }}</td>
            </tr>
          </tbody>
        </table>
        <div class="card-content text-center" v-if="all_or_filtered.length == 0 || all_or_filtered == null">
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
      ping_things: {
        type: Array,
        required: true
      },
      network: {
        type: String,
        required: true
      }
    },

    data() {
      return {
        filter_time: null,
        show_filtered_records: false,
        api_url: '/api/v1/ping-thing/' + this.network,
        ping_things_filtered: []
      }
    },

    computed: {
      all_or_filtered() {
        if(this.show_filtered_records) {
          return this.ping_things_filtered
        } else {
          return this.ping_things
        }
      }
    },

    methods: {
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

      get_filtered_records() {
        var ctx = this

        axios.get(ctx.api_url, { params: { time_filter: ctx.filter_time }})
             .then(function(response) {
               ctx.ping_things_filtered = response.data;
               ctx.show_filtered_records = true
             })
      },

      reset_filter() {
        this.filter_time = null
        this.show_filtered_records = false
        this.ping_things_filtered = []
      }
    }
  }
</script>
