<template>
  <div>
    <div class="page-header">
      <h1>Ping Thing</h1>
      <p>
        We use this Ping Thing to show recent transaction confirmation times on the Solana blockchain. The <a href='https://www.blocklogic.net' target='_blank'>Block Logic Validator</a> is sending simple transfer transactions every 15 seconds and the confirmation times appear below. You can use these pings as a gauge of cluster performance.
      </p>
      <p>
        This is a very simple first iteration with many improvements on the way. Upcoming features include: REST API to download data, interactive chart with custom timeframes, statistics for a given period of time, and more.
      </p>
      <p>
        App developers, you can also upload your own TX confirmation times using our <a href="/api-documentation">REST API</a>. Any Solana application or transaction type is allowed. Use this tool to show recent confirmation times to your users.
      </p>
      <p>
        I would like to get feedback from Solana developers on how we can make this tool more useful for your applications. Please contact me at @ValidatorsApp on Twitter. -- @brianlong
      </p>
      <p>
        NOTES: We use a 60-second timeout threshold for the pings. On the chart and table below, a value of 60,000 milliseconds means that the operation failed or took longer than 60 seconds to complete.
      </p>
      <div class="text-danger">This feature is a work-in-progress. Please contact @ValidatorsApp on Twitter with feedback.</div>
    </div>
    <div class="card mb-4">
      <div class="card-content">
        <h3 class="card-heading mb-4">{{ network }} TX Confirmation Time</h3>
        <scatter-chart :vector="ping_things" fill_color="rgba(221, 154, 229, 0.4)" line_color="rgb(221, 154, 229)"/>
      </div>
    </div>

    <div class="card">
      <div class="table-responsive-lg">
        <table class='table mb-0'>
          <thead>
          <tr>
            <th class="align-middle column-md-sm">Success / Time</th>
            <th class="align-middle column-lg">
              Reported&nbsp;At<br />
              <span class="small text-muted">Signature</span>
            </th>
            <th class="align-middle column-lg">
              Application<br />
              <span class="small text-muted">Type (Commitment Level)</span>
            </th>
            <th class="align-middle column-xs">Posted&nbsp;By</th>
          </tr>
          </thead>

          <tbody>
            <tr v-for="(pt, index) in ping_things" :key="pt.id">
              <td class="align-middle">
                <span v-html="success_icon(pt.success)"></span>
                <strong class="text-success h6">{{ pt.response_time.toLocaleString() }}</strong>&nbsp;ms
              </td>
              <td class="align-middle small">
                {{ pt.reported_at }}<br />
                <span class="word-break">
                  <a :href="link_from_signature(pt.signature)" target="_blank" class="small">
                    {{ pt.signature.substring(0,6) + "..." + pt.signature.substring(pt.signature.length - 4, pt.signature.length) }}
                  </a>
                </span>
              </td>
              <td class="align-middle small">
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
              <td class="align-middle text-muted">{{ pt.username }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import loadingImage from 'loading.gif'
  import scatterChart from './scatter_chart'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    props: ['network'],
    data () {
      return {
        ping_things: []
      }
    },
    created () {
      var ctx = this
      axios.get("/api/v1/ping-thing/testnet")
           .then(function(response){
             ctx.ping_things = response.data
           })
    },
    methods: {
      success_icon(success) {
        if(success){
          return '<i class="fas fa-check-circle text-success mr-1"></i>'
        } else {
          return '<i class="fas fa-times-circle text-danger mr-1"></i>'
        }
      },
      link_from_signature(signature){
        return "https://solanabeach.io/transaction/" + signature
      },
      transaction_type_icon(tx){
        switch(tx){
          case 'transfer':
            return '<i class="fas fa-exchange-alt text-success mr-1"></i>'
          default:
            return '<i class="fas fa-random text-success mr-1"></i>'
        }
      }
    },
    components: {
      "scatter-chart": scatterChart
    }
  }

</script>
