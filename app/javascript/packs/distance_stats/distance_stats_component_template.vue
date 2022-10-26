<template>
  <div class="row">
    <div class="col-md-6 mb-4">
      <div class="card">
        <div class="card-content">
          <h2 class="h4 card-heading">Root Distance</h2>
          <div class="row px-3 px-xl-5 mb-md-2">
            <small class="text-muted" v-if="!root_distance">loading...</small>
            <div class="stat col-5 my-auto" v-if="root_distance">
              <small class="text-muted">Median:</small>
              <div class="h5 text-purple">
                {{ root_distance_median() }}
              </div>
              <small class="text-muted">Average:</small>
              <div class="h5 text-purple">
                {{ root_distance_average() }}
              </div>
            </div>
            <div class="stat col-7 my-auto px-0" v-if="root_distance">
              <div class="text-muted">
                <i class="fas fa-long-arrow-alt-down text-purple"></i>Min &ndash;
                <i class="fas fa-long-arrow-alt-up text-purple"></i>Max:
              </div>
              <div class="stat-title-2 text-purple">
                {{ root_distance_min() }} &ndash; {{ root_distance_max() }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-md-6 mb-4">
      <div class="card">
        <div class="card-content">
          <h2 class="h4 card-heading">Vote Distance</h2>
          <div class="row px-3 px-xl-5 mb-md-2">
            <small class="text-muted" v-if="!vote_distance">loading...</small>
            <div class="stat col-5 my-auto" v-if="vote_distance">
              <small class="text-muted">Median:</small>
              <div class="h5 text-purple">
                {{ vote_distance_median() }}
              </div>
              <small class="text-muted">Average:</small>
              <div class="h5 text-purple">
                {{ vote_distance_average() }}
              </div>
            </div>
            <div class="stat col-7 my-auto px-0" v-if="vote_distance">
              <div class="text-muted">
                <i class="fas fa-long-arrow-alt-down text-purple"></i>Min &ndash;
                <i class="fas fa-long-arrow-alt-up text-purple"></i>Max:
              </div>
              <div class="stat-title-2 text-purple">
                {{ vote_distance_min() }} &ndash; {{ vote_distance_max() }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import millify from "millify";
  import { mapGetters } from 'vuex';

  export default {
    data() {
      return {
        root_distance: null,
        vote_distance: null
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
      root_distance_median() {
        return this.root_distance.median.toFixed(0);
      },
      root_distance_average() {
        return millify(parseFloat(this.root_distance.average) / 1000, { units: ["K", "M", "B"], precision: 2 } );
      },
      root_distance_min() {
        return this.root_distance.min.toFixed(0);
      },
      root_distance_max() {
        return millify(parseFloat(this.root_distance.max) / 1000, { units: ["K", "M", "B"], precision: 0 });
      },
      vote_distance_median() {
        return this.vote_distance.median.toFixed(0);
      },
      vote_distance_average() {
        return millify(parseFloat(this.root_distance.average) / 1000, { units: ["K", "M", "B"], precision: 2 });
      },
      vote_distance_min() {
        return this.vote_distance.min.toFixed(0);
      },
      vote_distance_max() {
        return millify(parseFloat(this.root_distance.max) / 1000, { units: ["K", "M", "B"], precision: 0 });
      }
    }
  }
</script>
