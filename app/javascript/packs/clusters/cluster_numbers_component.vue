<template>
  <div class="col-sm-6 col-md-4 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Cluster</h2>
        <div class="text-muted" v-if="!software_version">loading...</div>

        <div class="mb-2" v-if="software_version">
          <span class="text-muted me-1">Software Version:</span>
          <strong class="text-success">{{ software_version }}</strong>
        </div>
        <div v-if="validators_count">
          <span class="text-muted me-1">Validators:</span>
          <strong class="text-success">{{ validators_count }}</strong>
        </div>
        <div v-if="nodes_count">
          <span class="text-muted me-1">RPC nodes:</span>
          <strong class="text-success">{{ nodes_count }}</strong>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import Vue from 'vue/dist/vue.esm'
  import ActionCableVue from "actioncable-vue"

  Vue.use(ActionCableVue, {
    debug: true,
    debugLevel: "error",
    connectionUrl: "/cable",
    connectImmediately: true,
  })

  const ClusterNumbersComponent = Vue.component('ClusterNumbersComponent', {
    data() {
      return {
        connection: null,
        validators_count: null,
        nodes_count: null,
        software_version: null
      }
    },
    computed: mapGetters([
      'network'
    ]),
    mounted: function(){
      this.$cable.subscribe({
          channel: "FrontStatsChannel",
          room: "public",
        });
    },
    channels: {
      FrontStatsChannel: {
        connected() {},
        rejected() {},
        received(data) {
          this.validators_count = data.cluster_stats[this.network].validator_count
          this.nodes_count = data.cluster_stats[this.network].nodes_count
          this.software_version = data.cluster_stats[this.network].software_version
        },
        disconnected() {},
      },
    },
  })

  export default ClusterNumbersComponent
</script>
