<template>
  <div class="card col-md-3 col-sm-6">
    <div class="card-content">
      <h2 class="h3">Transactions</h2>
      <span class="stat-title-4" v-if="total_transactions_count">
        total count: 
        <span class="text-success">
          {{ total_transactions_count.toLocaleString() }}
        </span>
      </span>
      <br />
      <span class="stat-title-4" v-if="total_transactions_count">
        per second: 
        <span class="text-success">
          {{ transactions_per_second ? transactions_per_second.toFixed(0) : null }}
        </span>
      </span>
    </div>  
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js"

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
      this.connection = new web3.Connection(web3.clusterApiUrl('mainnet-beta'))
    },
    mounted() {
      this.get_total_transactions_count()
      this.get_1_sec_data()
    },
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
      get_last_block_info: function() {
        var ctx = this
        ctx.connection.getBlockProduction()
        .then(function (resp) {
          console.log(resp)
        })
      },
      get_1_sec_data: function() {
        var ctx = this
        setTimeout(function(){
          ctx.get_total_transactions_count()
          ctx.get_1_sec_data()
        }, ctx.gather_interval * 1000)
      }
    }
  }
</script>
