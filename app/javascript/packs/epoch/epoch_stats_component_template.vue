<template>
  <div class="card col-md-3 col-sm-6">
    <div class="card-content">
      <strong class="stat-title-4">
        epoch: 
        <span class="text-muted">
          {{ epoch_number }} 
        </span>
        <span class="text-success">
          ({{complete_percent}}%)
        </span>
      </strong><br />
      <strong class="stat-title-4">
        block height: 
        <span class="text-success">
          {{ block_height ? block_height.toLocaleString() : null }}
        </span>
      </strong>
      <strong class="stat-title-4">
        slot height: 
        <span class="text-success">
          {{ slot_height ? slot_height.toLocaleString() : null }}
        </span>
      </strong>
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
        block_height: null,
        slot_height: null,
        epoch_number: null,
        complete_percent: null
      }
    },
    created() {
      this.connection = new web3.Connection(web3.clusterApiUrl('mainnet-beta'))
    },
    mounted() {
      this.get_epoch_info()
      this.get_1_sec_data()
    },
    methods: {
      get_epoch_info: function() {
        var ctx = this
        ctx.connection.getEpochInfo()
        .then(function (resp) {
          console.log(resp)
          ctx.block_height = resp.blockHeight
          ctx.slot_height = resp.absoluteSlot
          ctx.epoch_number = resp.epoch
          ctx.complete_percent = ((resp.slotIndex / resp.slotsInEpoch) * 100).toFixed(2)
        })
      },
      get_1_sec_data: function() {
        var ctx = this
        setTimeout(function(){
          ctx.get_epoch_info()
          ctx.get_1_sec_data()
        }, ctx.gather_interval * 1000)
      }
    }
  }
</script>
