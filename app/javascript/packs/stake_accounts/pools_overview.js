import Vue from 'vue/dist/vue.esm'

var StakePoolsOverview = Vue.component('StakePoolsOverview', {
  props: {
    stake_pools: {
      type: Array,
      required: true
    }
  },
  data() {
    return {}
  },
  methods: {
    go_to_metrics() {
      document.getElementById("metrics").scrollIntoView()
    }
  },
  template: `
    <div class="card h-100">
      <div class="card-content">
        <h3 class="card-heading mb-2">
          Stake Pools overview
        </h3>
        <div class="text-center text-muted small mb-4">
          <a href="#" @click.prevent="go_to_metrics()">See metrics explanation</a>
        </div>

        <div v-for="pool in stake_pools">
          {{ pool.name }}
        </div>
      </div>
    </div>
  `
})

export default StakePoolsOverview
