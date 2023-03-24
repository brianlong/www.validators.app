import Vue from 'vue/dist/vue.esm'

const EpochMainComponent = Vue.component('EpochMainComponent', {
  props: {
    slot_height: {
      type: Number
    },
    block_height: {
      type: Number
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
    <div class= "col-md-4 col-sm-4 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h5 card-heading-left">Epoch</h2>

          <div>
            <span class="text-muted me-1">Slot Height:</span>
            <strong class="text-success">
              {{ slot_height? slot_height.toLocaleString('en-US', { maximumFractionDigits: 0 }) : null }}
            </strong>
          </div>

          <div class="mb-4">
            <span class="text-muted me-1">Block Height:</span>
            <strong class="text-success">
              {{ block_height? block_height.toLocaleString('en-US', { maximumFractionDigits: 0 }) : null }}
            </strong>
          </div>
        </div>
      </div>
    </div> 
  `
})

export default EpochMainComponent
