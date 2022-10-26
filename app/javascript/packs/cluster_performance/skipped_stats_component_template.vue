<template>
</template>

<script>
  import { mapGetters } from 'vuex';

  export default {
    data() {
      return {
        skipped_votes: null,
        skipped_slots: null
      }
    },
    channels: {
      FrontStatsChannel: {
        connected() { },
        rejected() { },
        received(data) {
          const cluster_stat = data.cluster_stats[this.network];
          this.skipped_votes = cluster_stat.skipped_votes;
          this.skipped_slots = cluster_stat.skipped_slots;

        },
        disconnected() { }
      }
    },
    mounted() {
      this.$cable.subscribe({
        channel: 'FrontStatsChannel',
        room: "public"
      });
    },
    computed: mapGetters([
      'network'
    ]),
    methods: {
      skipped_votes_median() {
        return (parseFloat(this.skipped_votes.median) * 100).toFixed(1);
      },
      skipped_votes_average() {
        return (parseFloat(this.skipped_votes.average) * 100).toFixed(1);
      },
      skipped_votes_best() {
        return (parseFloat(this.skipped_votes.best) * 100).toFixed(2);
      },
      skipped_slots_median() {
        return (parseFloat(this.skipped_slots.median) * 100).toFixed(1);
      },
      skipped_slots_average() {
        return (parseFloat(this.skipped_slots.average) * 100).toFixed(1);
      },
      skipped_slots_min() {
        const min = parseFloat(this.skipped_slots.min) * 100;

        return min > 0 ? min : 0;
      },
      skipped_slots_max() {
        return parseFloat(this.skipped_slots.max) * 100;
      }
    }
  }
</script>
