<template>
  <div class="col-md-4 col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Transactions</h2>

        <div v-if="total_transactions_count">
          <span class="text-muted me-1">Total:</span>
          <strong class="text-success">
            {{ total_transactions_count.toLocaleString('en-US', { maximumFractionDigits: 0 }) }}
          </strong>
        </div>

        <div v-if="total_transactions_count">
          <span class="text-muted me-1">TPS:</span>
          <strong class="text-success">
            {{ transactions_per_second ? transactions_per_second.toFixed(0) : null }}
          </strong>
          <span class="text-muted" v-if="!transactions_per_second">
            calculating...
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js"
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        connection: null,
        gather_interval: 5, // Seconds
        total_transactions_count: null,
        transactions_per_second: null
      }
    },

    created() {
      this.connection = new web3.Connection(this.web3_url)
    },

    mounted() {
      this.get_total_transactions_count()
      this.get_1_sec_data()
    },

    computed: mapGetters([
      'web3_url'
    ]),

    methods: {
      get_total_transactions_count: function() {
        var ctx = this
        ctx.connection.getTransactionCount()
        .then(function (resp) {
          if(ctx.total_transactions_count && resp) {
            ctx.transactions_per_second = (resp - ctx.total_transactions_count) / ctx.gather_interval
          }
          ctx.total_transactions_count = resp
        })
      },

      get_1_sec_data: function() {
        var ctx = this
        setTimeout(function() {
          ctx.get_total_transactions_count()
          ctx.get_1_sec_data()
        }, ctx.gather_interval * 1000)
      }
    }
  }
</script>
