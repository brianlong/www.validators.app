<template>
  <div class="col-lg-4 mb-4">
    <div class="card h-100">
      <div class="card-content">
        <h2 class="h5 card-heading-left">Cluster</h2>
        <div class="text-muted" v-if="!software_versions">loading...</div>

        <div class="mb-2" v-if="software_versions">
          <div class="text-muted me-1">Software Versions:</div>
          <div class="d-inline-block" v-if="software_versions['agave']">
            <strong class="text-success">{{ software_versions['agave'] }}</strong>&nbsp;
            <img :src="agave_icon" class="img-xxs" title="Agave" alt="A" style="margin-top: -4px;">
          </div>
          <div class="d-inline-block" v-if="software_versions['firedancer']">
            <strong class="ms-3 text-success">{{ software_versions['firedancer'] }}</strong>
            <img :src="firedancer_icon" class="img-xs" title="Firedancer" alt="F" style="margin-top: -3px; margin-left: 3px">
          </div>
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
  import agaveIcon from 'agave.svg'
  import firedancerIcon from 'firedancer.svg'

  export default {
    data() {
      return {
        connection: null,
        validators_count: null,
        nodes_count: null,
        software_versions: null,
        agave_icon: agaveIcon,
        firedancer_icon: firedancerIcon
      }
    },

    computed: mapGetters([
      'network'
    ]),

    mounted: function() {
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
          this.software_versions = data.cluster_stats[this.network].software_versions
        },
        disconnected() {},
      },
    },
  }
</script>
