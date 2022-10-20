import Vue from 'vue/dist/vue.esm'

var ValidatorsMapDataCenterDetails = Vue.component('ValidatorsMapDataCenterDetails', {
  props: {
    data_centers_group: {
      type: Object,
      required: true
    },
  },
  data() {
    return {}
  },
  methods: {},
  template: `
    <div>
      <strong class="text-purple">
        {{ data_centers_group.identifier }}, 
        {{ data_centers_group.data_centers.length }} Data Center(s)
      </strong>
      
      <div class="small" v-if="data_centers_group.active_validators_count > 0">
        <strong class="text-purple">
          {{ data_centers_group.active_validators_count }}
        </strong>
        <span class="text-muted">validator(s)</span>
      </div>
      
      <div class="small" v-if="data_centers_group.active_gossip_nodes_count > 0">
        <strong class="text-purple">
          {{ data_centers_group.active_gossip_nodes_count }}
        </strong>
        <span class="text-muted">RPC node(s)</span>
      </div>
    </div>
  `
})

export default ValidatorsMapDataCenterDetails
