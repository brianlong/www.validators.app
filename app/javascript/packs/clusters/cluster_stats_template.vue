<template>
  <section class="row">
    <EpochMainComponent
      :slot_height="slot_height"
      :block_height="block_height" />
    <EpochProgressComponent
      :epoch_number="epoch_number"
      :complete_percent="complete_percent"
      :epoch_graph_position="epoch_graph_position" />
    <ClusterNumbersComponent />
  </section>
</template>

<script>
  import * as web3 from "@solana/web3.js"
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        connection: null,
        gather_interval: 5,
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
      "web3_url"
    ]),
    methods: {
      get_epoch_info: function () {
        var ctx = this;
        ctx.connection.getEpochInfo()
          .then(function (resp) {
            ctx.block_height = resp.blockHeight
            ctx.slot_height = resp.absoluteSlot
            ctx.epoch_number = resp.epoch
            ctx.complete_percent = ((resp.slotIndex / resp.slotsInEpoch) * 100).toFixed(2)
            ctx.epoch_graph_position = ctx.complete_percent + "%"
          })
      },
      get_1_sec_data: function () {
        var ctx = this
        setTimeout(function () {
          ctx.get_epoch_info()
          ctx.get_1_sec_data()
        }, ctx.gather_interval * 1000)
      }
    }
  }
</script>
