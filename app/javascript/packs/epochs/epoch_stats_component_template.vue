<template>
  <div class="col-lg-8 col-md-12">
    <div class="row h-100">
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

            <div class="mb-3">
              <span class="text-muted me-1">Block Height:</span>
              <strong class="text-success">
                {{ block_height ? block_height.toLocaleString('en-US', {maximumFractionDigits: 0}) : null }}
              </strong>
            </div>

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

      <div class="col-md-6 mb-4">
        <div class="card h-100">
          <div class="card-content">
            <h2 class="h5 card-heading-left">Epochs History</h2>
            <canvas id="epoch-duration-bar-chart" width="600" height="220"></canvas>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import * as web3 from "@solana/web3.js"
  import { mapGetters } from 'vuex'
  import axios from 'axios'
  import Chart from 'chart.js/auto';
  import chart_variables from '../validators/charts/chart_variables'

  axios.defaults.headers.get["Authorization"] = window.api_authorization

  export default {
    data() {
      return {
        connection: null,
        gather_interval: 5, // Seconds
        block_height: null,
        slot_height: null,
        epoch_number: null,
        complete_percent: null,
        epoch_graph_position: null,
        epoch_history: null,
        _epochDurationChart: null
      }
    },

    created() {
      this.connection = new web3.Connection(this.web3_url)
    },

    mounted() {
      this.get_epoch_info()
      this.get_1_sec_data()
      this.get_epoch_history()
    },

    computed: mapGetters([
      'web3_url', 'network'
    ]),

    watch: {
      epoch_history(newVal) {
        this.renderEpochDurationChart()
      }
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
          ctx.epoch_graph_position = ctx.complete_percent + '%'
        })
      },

      get_1_sec_data: function() {
        var ctx = this
        setTimeout(function() {
          ctx.get_epoch_info()
          ctx.get_1_sec_data()
        }, ctx.gather_interval * 1000)
      },

      get_epoch_history: function() {
        var ctx = this
        let api_url = '/api/v1/epochs/' + this.network
        axios.get(api_url)
        .then(function (resp) {
          let epochs = resp.data['epochs'].sort((a, b) => a.epoch - b.epoch)
          for (let i = 0; i < epochs.length - 1; i++) {
            epochs[i].ends_at = epochs[i + 1].created_at
            const start = new Date(epochs[i].created_at)
            const end = new Date(epochs[i].ends_at)
            epochs[i].duration_minutes = Math.floor((end - start) / (1000 * 60))
          }
          if (epochs.length > 0) {
            epochs.pop()
          }
          const lastEpochs = epochs.slice(-20)
          ctx.epoch_history = lastEpochs
        })
      },

      renderEpochDurationChart() {
        if (!this.epoch_history || this.epoch_history.length === 0) return
        const ctx = document.getElementById('epoch-duration-bar-chart').getContext('2d')
        if (this._epochDurationChart) {
          this._epochDurationChart.destroy()
        }
        const minDuration = Math.min(...this.epoch_history.map(e => e.duration_minutes))
        const yMin = Math.max(0, minDuration - 120)
        this._epochDurationChart = new Chart(ctx, {
          type: 'bar',
          data: {
            labels: this.epoch_history.map(e => e.epoch),
            datasets: [{
              label: 'Czas trwania epochy (minuty)',
              data: this.epoch_history.map(e => e.duration_minutes),
              backgroundColor: chart_variables.chart_purple_3_t,
              borderColor: chart_variables.chart_purple_3_t,
              borderWidth: 1,
              barPercentage: 0.5,
              categoryPercentage: 0.5,
              borderRadius: 8
            }]
          },
          options: {
            responsive: true,
            plugins: {
              legend: { display: false },
              tooltip: {
                displayColors: false,
                callbacks: {
                  title: () => '',
                  label: (context) => {
                    const epoch = this.epoch_history[context.dataIndex]
                    let durationStr = '—'
                    if (epoch.duration_minutes && !isNaN(epoch.duration_minutes)) {
                      const hours = Math.floor(epoch.duration_minutes / 60)
                      const minutes = epoch.duration_minutes % 60
                      durationStr = `${hours}h ${minutes}m`
                    }
                    const createdAt = epoch.created_at ? new Date(epoch.created_at).toLocaleString() : '—'
                    const endsAt = epoch.ends_at ? new Date(epoch.ends_at).toLocaleString() : '—'
                    return [
                      `Epoch: ${epoch.epoch}`,
                      `Duration: ${durationStr}`,
                      `Start: ${createdAt}`,
                      `End: ${endsAt}`
                    ]
                  }
                }
              }
            },
            scales: {
              x: { 
                ticks: { display: false },
                grid: { display: false }
              },
              y: { 
                beginAtZero: true,
                min: yMin,
                ticks: { display: false, stepSize: 60 },
                grid: { display: true, color: chart_variables.chart_grid_color, lineWidth: 1, drawTicks: false } 
              }
            }
          }
        })
      }
    }
  }
</script>
