import Vue from 'vue/dist/vue.esm'

const EpochProgressComponent = Vue.component('EpochProgressComponent', {
  props: {
    epoch_number: {
      type: Number
    },
    complete_percent: {
      type: String
    },
    epoch_graph_position: {
      type: String
    }
  },
  data() {
    return {
      chart: null
    }
  },
  methods: {
  },
  template: `
    <div class="col-md-4 col-sm-4 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h5 card-heading-left">Epoch Progress</h2>

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
  `
})

export default EpochProgressComponent
