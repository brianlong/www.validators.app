<template>
  <section class="row">
    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h5 card-heading-left">Epoch</h2>

          <div>
            <span class="text-muted me-1">Slot Height:</span>
            <strong class="text-success">
              {{ slot_height ? slot_height.toLocaleString('en-US', {maximumFractionDigits: 0}) : null }}
            </strong>
          </div>

          <div class="mb-4">
            <span class="text-muted me-1">Block Height:</span>
            <strong class="text-success">
              {{ block_height ? block_height.toLocaleString('en-US', {maximumFractionDigits: 0}) : null }}
            </strong>
          </div>
        </div>
      </div>
    </div>

    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h5 card-heading-left">Epoch Progress</h2>

          <div class="d-flex justify-content-between gap-3">
            <div>
              <span class="text-muted me-1">Current Epoch:</span>
              <strong class="text-success">{{ epoch_number }}</strong>
            </div>
            <div>{{ complete_percent }}%</div>
          </div>

          <div class="img-line-graph mt-3">
            <div class="img-line-graph-fill" :style="{ width: epoch_graph_position }"></div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import * as web3 from "@solana/web3.js"
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        connection: null,
        gather_interval: 5, // Seconds
        block_height: null,
        slot_height: null,
        epoch_number: null,
        complete_percent: null,
        epoch_graph_position: null
      }
    },
    created() {
      this.connection = new web3.Connection(this.web3_url)
    },
    mounted() {
      this.get_epoch_info()
      this.get_1_sec_data()
    },
    computed: mapGetters([
      'web3_url'
    ]),
    methods: {
      get_epoch_info: function() {
        var ctx = this
        ctx.connection.getEpochInfo()
        .then(function (resp) {
          ctx.block_height = resp.blockHeight
          ctx.slot_height = resp.absoluteSlot
          ctx.epoch_number = resp.epoch
          ctx.complete_percent = ((resp.slotIndex / resp.slotsInEpoch) * 100).toFixed(2)
          ctx.epoch_graph_position = ctx.complete_percent + '%'
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
