<template>
  <div>
    <div class="btn-group flex-wrap mb-4" aria-label="epochs" v-if="epochs.length > 0">
      <button v-for="epoch in epochs"
              :key="epoch"
              type="button"
              :class="['btn', 'btn-sm', epoch === current_epoch ? 'btn-primary' : 'btn-secondary']"
              @click="select_epoch(epoch)">
        Epoch {{ epoch }}
      </button>
    </div>

    <div class="card mb-4" v-if="loading && !stats">
      <div class="card-content">
        <small class="text-muted">loading...</small>
      </div>
    </div>

    <div class="card mb-4" v-if="!loading && !stats">
      <div class="card-content">
        <p class="mb-0 text-muted">No Alpenglow statistics are available for {{ network }} yet.</p>
      </div>
    </div>

    <div v-if="stats">
      <h2 class="h4 mb-3">
        Cluster
        <small class="text-muted">epoch {{ stats.epoch }}</small>
      </h2>

      <section class="row">
        <div class="col-sm-6 col-lg-3 mb-4">
          <div class="card h-100">
            <div class="card-content">
              <h3 class="h6 card-heading-left">Fast Finalization</h3>
              <div class="h2 mb-2">
                <strong class="text-purple">{{ format_percent(stats.fast_percent) }}</strong>
              </div>
              <div class="text-muted small">
                {{ format_number(stats.fast_finalized) }} fast,
                {{ format_number(stats.slow_finalized) }} slow
                of {{ format_number(stats.finalized_blocks) }} certified blocks
              </div>
            </div>
          </div>
        </div>

        <div class="col-sm-6 col-lg-3 mb-4">
          <div class="card h-100">
            <div class="card-content">
              <h3 class="h6 card-heading-left">Finalization Lag</h3>
              <div class="h2 mb-2">
                <strong class="text-purple">{{ format_decimal(stats.average_final_lag) }}</strong>
                <span class="h6 text-muted">slots</span>
              </div>
              <div class="text-muted small">
                Average distance between a block and the first footer carrying its finalization certificate
              </div>
            </div>
          </div>
        </div>

        <div class="col-sm-6 col-lg-3 mb-4">
          <div class="card h-100">
            <div class="card-content">
              <h3 class="h6 card-heading-left">Footers With Certificate</h3>
              <div class="h2 mb-2">
                <strong class="text-purple">{{ format_percent(stats.final_cert_percent) }}</strong>
              </div>
              <div class="text-muted small">
                Share of produced blocks whose footer includes a finalization certificate
              </div>
            </div>
          </div>
        </div>

        <div class="col-sm-6 col-lg-3 mb-4">
          <div class="card h-100">
            <div class="card-content">
              <h3 class="h6 card-heading-left">Observed Blocks</h3>
              <div class="h2 mb-2">
                <strong class="text-purple">{{ format_number(stats.leader_slots) }}</strong>
              </div>
              <div class="text-muted small">
                produced by {{ format_number(stats.leaders) }} leaders
                <span v-if="stats.updated_at"><br>updated {{ time_ago(stats.updated_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <div class="card mb-4">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr>
                <th colspan="4"><h3 class="h6 mb-0">Leader Clients</h3></th>
              </tr>
              <tr>
                <th>Client</th>
                <th class="text-end">Leaders</th>
                <th class="text-end">Blocks</th>
                <th>Versions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="client in stats.clients" :key="client.client">
                <td><strong>{{ client.client }}</strong></td>
                <td class="text-end">{{ client.leaders }}</td>
                <td class="text-end">
                  {{ format_number(client.leader_slots) }}
                  <span class="text-muted">({{ format_percent(client.leader_slots_percent || 0) }})</span>
                </td>
                <td class="small text-muted">{{ client.versions.join(', ') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import axios from 'axios'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    data() {
      return {
        refresh_interval: 60, // Seconds
        refresh_timeout: null,
        loading: true,
        epochs: [],
        selected_epoch: null,
        stats: null,
        now: Date.now()
      }
    },

    mounted() {
      this.get_stats()
      this.schedule_refresh()
    },

    beforeDestroy() {
      clearTimeout(this.refresh_timeout)
    },

    computed: {
      ...mapGetters([
        'network'
      ]),

      api_url() {
        let url = '/api/v1/alpenglow-cluster-stats/' + this.network
        if (this.selected_epoch) {
          url += '?epoch=' + this.selected_epoch
        }
        return url
      },

      current_epoch() {
        return this.stats ? this.stats.epoch : null
      }
    },

    methods: {
      get_stats() {
        var ctx = this
        return axios.get(ctx.api_url)
          .then(function (response) {
            ctx.epochs = response.data.epochs
            ctx.stats = response.data.cluster_stats
            ctx.now = Date.now()
          })
          .finally(function () {
            ctx.loading = false
          })
      },

      schedule_refresh() {
        var ctx = this
        ctx.refresh_timeout = setTimeout(function () {
          ctx.get_stats()
          ctx.schedule_refresh()
        }, ctx.refresh_interval * 1000)
      },

      select_epoch(epoch) {
        this.selected_epoch = epoch === this.epochs[0] ? null : epoch
        this.get_stats()
      },

      format_percent(value) {
        return value === null || value === undefined ? 'N/A' : value.toFixed(1) + '%'
      },

      format_decimal(value) {
        return value === null || value === undefined ? 'N/A' : value.toFixed(2)
      },

      format_number(value) {
        return value === null || value === undefined ? 'N/A' : value.toLocaleString('en-US')
      },

      time_ago(timestamp) {
        const minutes = Math.max(0, Math.floor((this.now - new Date(timestamp).getTime()) / 60000))
        if (minutes < 1) return 'less than a minute ago'
        if (minutes < 60) return minutes + (minutes === 1 ? ' minute ago' : ' minutes ago')
        const hours = Math.floor(minutes / 60)
        return hours + (hours === 1 ? ' hour ago' : ' hours ago')
      }
    }
  }
</script>
