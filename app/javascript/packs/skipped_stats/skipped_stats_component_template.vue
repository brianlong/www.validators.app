<template>
  <div class="row">
    <div class="col-md-6 mb-4">
      <div class="card">
        <div class="card-content">
          <h2 class="h4 card-heading">Skipped Vote&nbsp;&percnt;</h2>
          <div class="row px-3 px-xl-5 mb-md-2">
            <small class="text-muted" v-if="!skipped_votes">loading...</small>
            <div class="stat col-5" v-if="skipped_votes">
              <small class="text-muted">Median:</small>
              <div class="h5 text-success">
                {{ skipped_votes_median() }}%
              </div>
              <small class="text-muted">Average:</small>
              <div class="h5 text-success">
                {{ skipped_votes_average() }}%
              </div>
            </div>
            <div class="stat col-7 my-auto px-0" v-if="skipped_votes">
              <div class="text-muted"><i class="fas fa-trophy text-success"></i>Best:</div>
              <div class="stat-title-1 text-success">
                {{ skipped_votes_best() }}%
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-md-6 mb-4">
      <div class="card">
        <div class="card-content">
          <h2 class="h4 card-heading">Skipped Slot&nbsp;&percnt;</h2>
          <div class="row px-3 px-xl-5 mb-md-2">
            <small class="text-muted" v-if="!skipped_slots">loading...</small>
            <div class="stat col-5 my-auto" v-if="skipped_slots">
              <small class="text-muted">Median:</small>
              <div class="h5 text-success">
                {{ skipped_slots_median() }}%
              </div>
              <small class="text-muted">Average:</small>
              <div class="h5 text-success">
                {{ skipped_slots_average() }}%
              </div>
            </div>
            <div class="stat col-7 my-auto px-0" v-if="skipped_slots">
              <div class="text-muted">
                <i class="fas fa-long-arrow-alt-down text-success"></i>Min &ndash;
                <i class="fas fa-long-arrow-alt-up text-success"></i>Max:
              </div>
              <h2 class="stat-title-2 text-success mt-2">
                {{ skipped_slots_min() }}
                &ndash;
                {{ skipped_slots_max() }}
              </h2>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
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
