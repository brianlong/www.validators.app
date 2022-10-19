<template>
  <div>
    <div class="row mb-4">
      <div class="col-2">
        <input name="filter_time" v-model="filter_time" type="number" class="form-control" step="10">
      </div>
      <div class="col-3">
        <button
          @click.prevent="get_filtered_records()"
          class="btn btn-block btn-sm btn-success">
            set minimum time
        </button>
        <button
          @click.prevent="reset_filter()"
          class="btn btn-sm btn-block btn-secondary"
          v-if="ping_things_filtered.length > 0">
            reset
        </button>
      </div>
    </div>
    <div class="card">
      <div class="table-responsive-lg">
        <table class='table'>
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
                <strong class="text-success h6">{{ pt.response_time.toLocaleString() }}</strong>&nbsp;ms
              </td>
              <td class="small">
                {{ formatted_date(pt.reported_at) }}<br />
                <span class="word-break">
                  <a :href="link_from_signature(pt.signature)" target="_blank" class="small">
                    {{ pt.signature.substring(0,6) + "..." + pt.signature.substring(pt.signature.length - 4, pt.signature.length) }}
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
      </div>
    </div>
  </div>
</template>

<script>
  var moment = require('moment');
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
        api_url: '/api/v1/ping-thing/' + this.network,
        ping_things_filtered: []
      }
    },
    computed: {
      all_or_filtered() {
        if(this.ping_things_filtered.length > 0){
          return this.ping_things_filtered
        } else {
          return this.ping_things
        }
      }
    },
    methods: {
      success_icon(success) {
        if(success){
          return '<i class="fas fa-check-circle text-success me-1"></i>'
        } else {
          return '<i class="fas fa-times-circle text-danger me-1"></i>'
        }
      },
      link_from_signature(signature){
        return "https://solanabeach.io/transaction/" + signature
      },
      transaction_type_icon(tx){
        switch(tx){
          case 'transfer':
            return '<i class="fas fa-exchange-alt text-success me-1"></i>'
          default:
            return '<i class="fas fa-random text-success me-1"></i>'
        }
      },
      formatted_date(date){
        var date = new Date(date)
        var formatted_date = moment(date).utc().format('YYYY-MM-DD HH:mm:ss z')

        return formatted_date
      },
      slot_latency(sent, landed){
        if(sent && landed){
          return landed - sent
        } else {
          return " - "
        }
      },
      get_filtered_records() {
        var ctx = this

        axios.get(ctx.api_url + "?time_filter=" + this.filter_time)
           .then(function(response) {
             ctx.ping_things_filtered = response.data;
             console.log(ctx.ping_things_filtered)
           })
      },
      reset_filter() {
        this.filter_time = null
        this.ping_things_filtered = []
      }
    }
  }
</script>
