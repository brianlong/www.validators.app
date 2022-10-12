<template>
  <div class="col-sm-6 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Epoch</h2>

        <div>
          <span class="text-muted me-1">Slot Height:</span>
          <strong class="text-success">
            {{ slot_height ? slot_height.toLocaleString() : null }}
          </strong>
        </div>
        <div class="mb-3">
          <span class="text-muted me-1">Block Height:</span>
          <strong class="text-success">
            {{ block_height ? block_height.toLocaleString() : null }}
          </strong>
        </div>

        <div>
          <span class="text-muted me-1">Current Epoch:</span>
          <strong class="text-success">{{ epoch_number }}</strong>
          <small>({{complete_percent}}%)</small>
        </div>
      </div>
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
