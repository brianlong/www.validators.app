<template>
  <section class="row">
    <div class="col-sm-6 col-lg-3 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h3 class="h6 card-heading-left">Root Distance</h3>
          <small class="text-muted" v-if="!root_distance">loading...</small>

          <div class="text-muted mb-2" v-if="root_distance">
            <i class="fas fa-long-arrow-alt-down text-purple" aria-hidden="true"></i>
            {{ root_distance_min() }}
            &nbsp;–&nbsp;
            <i class="fas fa-long-arrow-alt-up text-purple" aria-hidden="true"></i>
            {{ root_distance_max() }}
          </div>

          <div v-if="root_distance">
            <span class="text-muted me-1">Median:</span>
            <strong class="text-purple">{{ root_distance_median() }}</strong>
          </div>

          <div v-if="root_distance">
            <span class="text-muted me-1">Average:</span>
            <strong class="text-purple">{{ root_distance_average() }}</strong>
          </div>
        </div>
      </div>
    </div>

    <div class="col-sm-6 col-lg-3 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h3 class="h6 card-heading-left">Vote Distance</h3>
          <small class="text-muted" v-if="!vote_distance">loading...</small>

          <div class="text-muted mb-2" v-if="vote_distance">
            <i class="fas fa-long-arrow-alt-down text-purple" aria-hidden="true"></i>
            {{ vote_distance_min() }}
            &nbsp;–&nbsp;
            <i class="fas fa-long-arrow-alt-up text-purple" aria-hidden="true"></i>
            {{ vote_distance_max() }}
          </div>

          <div v-if="vote_distance">
            <span class="text-muted me-1">Median:</span>
            <strong class="text-purple">{{ vote_distance_median() }}</strong>
          </div>

          <div v-if="vote_distance">
            <span class="text-muted me-1">Average:</span>
            <strong class="text-purple">{{ vote_distance_average() }}</strong>
          </div>
        </div>
      </div>
    </div>

    <div class="col-sm-6 col-lg-3 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h3 class="h6 card-heading-left">Skipped Vote&nbsp;&percnt;</h3>
          <small class="text-muted" v-if="!skipped_votes">loading...</small>

          <div class="text-muted mb-2" v-if="skipped_votes">
            <i class="fas fa-trophy text-purple me-1" aria-hidden="true"></i>
            Best:
            <strong class="text-purple ms-1">{{ skipped_votes_best() }}%</strong>
          </div>

          <div v-if="skipped_votes">
            <span class="text-muted me-1">Median:</span>
            <strong class="text-purple">{{ skipped_votes_median() }}%</strong>
          </div>

          <div v-if="skipped_votes">
            <span class="text-muted me-1">Average:</span>
            <strong class="text-purple">{{ skipped_votes_average() }}%</strong>
          </div>
        </div>
      </div>
    </div>

    <div class="col-sm-6 col-lg-3 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h3 class="h6 card-heading-left">Skipped Slot&nbsp;&percnt;</h3>
          <small class="text-muted" v-if="!skipped_slots">loading...</small>

          <div class="text-muted mb-2" v-if="skipped_slots">
            <i class="fas fa-long-arrow-alt-down text-purple" aria-hidden="true"></i>
            {{ skipped_slots_min() }}
            &nbsp;–&nbsp;
            <i class="fas fa-long-arrow-alt-up text-purple" aria-hidden="true"></i>
            {{ skipped_slots_max() }}
          </div>

          <div v-if="skipped_slots">
            <span class="text-muted me-1">Median:</span>
            <strong class="text-purple">{{ skipped_slots_median() }}%</strong>
          </div>

          <div v-if="skipped_slots">
            <span class="text-muted me-1">Average:</span>
            <strong class="text-purple">{{ skipped_slots_average() }}%</strong>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import millify from "millify";
  import { mapGetters } from 'vuex';

  export default {
    data() {
      return {
        root_distance: null,
        vote_distance: null,
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
          this.root_distance = cluster_stat.root_distance;
          this.vote_distance = cluster_stat.vote_distance;
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
      root_distance_average() {
        let average = parseFloat(this.root_distance.average);
        if(average < 0.01) {
          return "<0.01";
        }
        return millify(average, { units: ["", "K", "M", "B"], precision: 2 } );
      },
      root_distance_median() {
        let median = parseFloat(this.root_distance.median);
        if(median < 0.01) {
          return "<0.01";
        }
        return millify(median, { units: ["", "K", "M", "B"], precision: 2 } );
      },
      root_distance_min() {
        return this.root_distance.min.toFixed(0);
      },
      root_distance_max() {
        let max_distance = parseFloat(this.root_distance.max);
        let precision = max_distance > 0.01 ? 2 : 4
        return millify(max_distance, { units: ["", "K", "M", "B"], precision: precision });
      },

      vote_distance_average() {
        let average = parseFloat(this.vote_distance.average);
        if(average < 0.01) {
          return "<0.01";
        }
        return millify(average, { units: ["", "K", "M", "B"], precision: 2 } );
      },
      vote_distance_median() {
        let median = parseFloat(this.vote_distance.median);
        if(median < 0.01) {
          return "<0.01";
        }
        return millify(median, { units: ["", "K", "M", "B"], precision: 2 } );
      },
      vote_distance_min() {
        return this.vote_distance.min.toFixed(0);
      },
      vote_distance_max() {
        let max_distance = parseFloat(this.vote_distance.max);
        let precision = max_distance > 0.01 ? 2 : 4
        return millify(max_distance, { units: ["", "K", "M", "B"], precision: precision });
      },

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
